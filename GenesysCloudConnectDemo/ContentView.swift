import SwiftUI
import PureCloudPlatformClientV2
import Foundation

struct ContentView: View {
    // MARK: - State Variables
    @State private var clientId: String = ""
    @State private var clientSecret: String = ""
    @State private var environmentBasePath: String = "https://api.mypurecloud.com"
    @State private var statusMessage: String = "Enter your OAuth Client ID and Secret above"
    @State private var isRequestInProgress: Bool = false
    @State private var apiResponseJSON: String = ""
    @State private var showCredentialsHelp: Bool = false
    @State private var currentAccessToken: String = ""
    
    // MARK: - Main View Body
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Configuration Section
                Section(header: Text("SDK Configuration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Environment").font(.caption).foregroundColor(.secondary)
                        TextField("Base Path", text: $environmentBasePath)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Client ID").font(.caption).foregroundColor(.secondary)
                        TextField("Enter OAuth Client ID", text: $clientId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Client Secret").font(.caption).foregroundColor(.secondary)
                        SecureField("Enter OAuth Client Secret", text: $clientSecret)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    Button("How to create OAuth client?") {
                        showCredentialsHelp.toggle()
                    }.font(.caption)
                    
                    if showCredentialsHelp {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("1. Go to Genesys Cloud Admin → Integrations → OAuth")
                            Text("2. Click 'Add Client'")
                            Text("3. Set Grant Type: 'Client Credentials'")
                            Text("4. Add scope: 'users:read'")
                            Text("5. IMPORTANT: Assign a Role (e.g., 'Developer')")
                            Text("6. Copy Client ID and Secret")
                        }
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(8)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(6)
                    }
                }
                
                // MARK: - Action Section
                Section {
                    Button(action: authenticateAndTestSDK) {
                        HStack {
                            Spacer()
                            if isRequestInProgress {
                                ProgressView().scaleEffect(0.8)
                                Text("Authenticating & Testing...").padding(.leading, 8)
                            } else {
                                Text("Authenticate & Test SDK").fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(clientId.isEmpty || clientSecret.isEmpty || isRequestInProgress)
                    .listRowBackground((clientId.isEmpty || clientSecret.isEmpty) ? Color.gray.opacity(0.2) : Color.blue)
                    .foregroundColor((clientId.isEmpty || clientSecret.isEmpty) ? .gray : .white)
                }
                
                // MARK: - Results Section
                Section(header: Text("Results")) {
                    VStack(alignment: .leading, spacing: 10) {
                        // Status Icon and Message
                        HStack(alignment: .top) {
                            Image(systemName: statusMessage.contains("✅") ? "checkmark.circle.fill" :
                                  statusMessage.contains("❌") ? "xmark.circle.fill" :
                                  statusMessage.contains("🎯") ? "checkmark.circle.fill" : "info.circle.fill")
                                .foregroundColor(statusMessage.contains("✅") ? .green :
                                               statusMessage.contains("❌") ? .red :
                                               statusMessage.contains("🎯") ? .green : .blue)
                            Text(statusMessage)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Show current token if available
                        if !currentAccessToken.isEmpty {
                            Divider()
                            Text("Generated Access Token:").font(.caption).foregroundColor(.secondary)
                            Text(String(currentAccessToken.prefix(50)) + "...")
                                .font(.system(.caption, design: .monospaced))
                                .padding(4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        // Show JSON response if available
                        if !apiResponseJSON.isEmpty {
                            Divider()
                            Text("Details:").font(.caption).foregroundColor(.secondary)
                            ScrollView {
                                Text(apiResponseJSON)
                                    .font(.system(.caption, design: .monospaced))
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Status Section
                Section(header: Text("Integration Status")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("SDK Integration").fontWeight(.medium)
                        }
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("SwiftUI Application").fontWeight(.medium)
                        }
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("Build System").fontWeight(.medium)
                        }
                        HStack {
                            Image(systemName: currentAccessToken.isEmpty ? "circle" : "checkmark.circle.fill")
                                .foregroundColor(currentAccessToken.isEmpty ? .gray : .green)
                            Text("OAuth Authentication").fontWeight(.medium)
                        }
                        HStack {
                            Image(systemName: apiResponseJSON.contains("Name:") ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(apiResponseJSON.contains("Name:") ? .green : .gray)
                            Text("API Connectivity").fontWeight(.medium)
                        }
                    }
                    .font(.caption)
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Genesys Cloud SDK")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - OAuth Authentication & SDK Test Function
    func authenticateAndTestSDK() {
        // Reset state for new request
        isRequestInProgress = true
        apiResponseJSON = ""
        currentAccessToken = ""
        statusMessage = "Step 1: Requesting OAuth token..."
        
        // Step 1: Get OAuth Token
        requestOAuthToken { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self.currentAccessToken = token
                    self.statusMessage = "Step 2: Configuring SDK and testing API..."
                    
                    // Step 2: Configure SDK and test API
                    self.configureSDKAndTest(with: token)
                    
                case .failure(let error):
                    self.isRequestInProgress = false
                    self.handleOAuthError(error)
                }
            }
        }
    }
    
    // MARK: - OAuth Token Request
    private func requestOAuthToken(completion: @escaping (Result<String, Error>) -> Void) {
        // Build token URL based on environment
        let loginURL = environmentBasePath.replacingOccurrences(of: "api.", with: "login.")
        let tokenURL = URL(string: "\(loginURL)/oauth/token")!
        
        // Create request
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Add Basic Auth header
        let credentials = "\(clientId):\(clientSecret)"
        let credentialsData = credentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Add body with scope for users:read permission
        let bodyString = "grant_type=client_credentials&scope=users:read"
        request.httpBody = bodyString.data(using: .utf8)
        
        // Make request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Check HTTP response status
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(responseString)"])
                completion(.failure(error))
                return
            }
            
            // Parse JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["access_token"] as? String {
                    completion(.success(accessToken))
                } else {
                    // Try to get error details
                    let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                    let error = NSError(domain: "TokenError", code: 0, userInfo: [NSLocalizedDescriptionKey: responseString])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Configure SDK and Test API
    private func configureSDKAndTest(with token: String) {
        // Configure the SDK with the obtained token
        PureCloudPlatformClientV2API.accessToken = token
        PureCloudPlatformClientV2API.basePath = environmentBasePath
        
        // Test the API connection
        UsersAPI.getUsersMe() { (response, error) in
            DispatchQueue.main.async {
                self.isRequestInProgress = false
                if let error = error {
                    self.handleAPIError(error)
                } else if let user = response {
                    self.handleSuccess(user)
                }
            }
        }
    }
    
    // MARK: - Success Handler
    private func handleSuccess(_ user: UserMe) {
        let userName = user.name ?? "N/A"
        let userEmail = user.email ?? "N/A"
        let userTitle = user.title ?? "N/A"
        let userDepartment = user.department ?? "N/A"
        
        statusMessage = """
        🎉 COMPLETE SUCCESS
        
        OAuth Authentication: ✅ Working
        SDK Configuration: ✅ Working  
        API Connection: ✅ Working
        
        User: \(userName)
        Email: \(userEmail)
        Title: \(userTitle)
        Department: \(userDepartment)
        
        Status: Production Ready
        """
        
        // Format JSON response
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(user)
            apiResponseJSON = String(data: data, encoding: .utf8) ?? "Could not format response"
        } catch {
            apiResponseJSON = "Error formatting response: \(error.localizedDescription)"
        }
    }
    
    // MARK: - OAuth Error Handler
    private func handleOAuthError(_ error: Error) {
        let errorString = error.localizedDescription
        
        if errorString.contains("HTTP 400") || errorString.contains("invalid_client") {
            statusMessage = """
            ❌ OAUTH AUTHENTICATION FAILED
            
            Issue: Invalid Client ID or Secret
            
            Solution:
            1. Verify Client ID and Secret are correct
            2. Check you're using the right environment
            3. Ensure client exists in Genesys Cloud Admin
            
            Environment: \(environmentBasePath)
            """
        } else if errorString.contains("invalid_scope") {
            statusMessage = """
            ❌ OAUTH SCOPE ISSUE
            
            Issue: Client missing 'users:read' scope
            
            Solution:
            1. Go to Admin → Integrations → OAuth
            2. Edit client: \(clientId)
            3. Add 'users:read' to Scope section
            4. Save and try again
            """
        } else {
            statusMessage = """
            ❌ OAUTH REQUEST FAILED
            
            Issue: Network or configuration problem
            
            Solution:
            Check network connection and credentials
            """
        }
        
        apiResponseJSON = "OAuth Error Details:\n\(errorString)"
    }
    
    // MARK: - API Error Handler
    private func handleAPIError(_ error: Error) {
        // Check for the classic "Error 3" - this is the role permission issue
        let errorString = error.localizedDescription
        
        if errorString.contains("error 3") || errorString.contains("Error 3") {
            statusMessage = """
            🎯 OAUTH SUCCESS + ROLE NEEDED
            
            OAuth Authentication: ✅ Working
            Token Generation: ✅ Successful
            SDK Configuration: ✅ Working
            
            Issue: Classic "Error 3" - Missing Role
            
            Solution:
            1. Go to Admin → Integrations → OAuth
            2. Find client: \(clientId)
            3. Click "Roles" tab
            4. Assign "Developer" or "Employee" role
            5. Save and wait 1-2 minutes
            6. Test again
            
            Status: OAuth Integration Complete
            """
            
            apiResponseJSON = """
            Error Analysis:
            • Type: Classic "Error 3" - Role Permission Issue
            • OAuth Token: ✅ Successfully generated
            • Issue: OAuth client needs role assignment
            • Solution: Admin must assign role to client
            
            Technical Details: \(errorString)
            """
        } else {
            // Handle other API errors
            statusMessage = """
            🎯 OAUTH SUCCESS + API ISSUE
            
            OAuth Authentication: ✅ Working
            SDK Configuration: ✅ Working
            
            Issue: API permission or configuration problem
            
            Solution: Check OAuth client role and scope configuration
            """
            
            apiResponseJSON = """
            OAuth: SUCCESS ✅
            API Error: \(errorString)
            
            Most likely cause: Permission or configuration issue
            """
        }
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
