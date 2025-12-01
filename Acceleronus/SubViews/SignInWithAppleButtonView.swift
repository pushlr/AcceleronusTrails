import AuthenticationServices
import SwiftUI

struct SignInWithAppleButtonView: View {
    var onSignedIn: (_ userId: String, _ email: String?, _ token: String?, _ fullName: PersonNameComponents?, _ nonce: String) -> Void
    @State private var nonce = randomNonceString()

    var body: some View {
        SignInWithAppleButton(.signIn, onRequest: { request in
            request.requestedScopes = [.email, .fullName]
            request.nonce = sha256(nonce)
        }, onCompletion: { result in
            switch result {
            case .success(let authResult):
                if let credential = authResult.credential as? ASAuthorizationAppleIDCredential {

                    let token = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
                    let email = credential.email
                    let userId = credential.user
                    let fullName = credential.fullName    // <-- IMPORTANT

                    onSignedIn(userId, email, token, fullName, nonce)
                }

            case .failure(let error):
                print("Apple sign in failed2:", error.localizedDescription)
            }
        })
        .signInWithAppleButtonStyle(.black)
    }
}

