import 'package:firebase_auth/firebase_auth.dart';

//
Future<UserCredential> signin_withgithub() async {
  GithubAuthProvider githubAuthProvider = GithubAuthProvider();
  return await FirebaseAuth.instance.signInWithProvider(githubAuthProvider);
}

// githih_login(BuildContext context) {
//   // create required params
//   var params = GithubParamsModel(
//     clientId: 'Ov23lip3LUul4nCLaIF5',
//     clientSecret: 'f92821074ac77e56b56af56e840c54cca119b3ff',
//     callbackUrl: 'https://lawapp-f7d44.firebaseapp.com/__/auth/handler',
//     scopes: 'read:user,user:email',
//   );

//   dynamic result = Navigator.push(context,
//       MaterialPageRoute(builder: (context) => GithubSignIn(params: params)));

//   if (result == null) {
//     // user cancelled the sign in or error occurred
//   }

//   var data = result as GithubSignInResponse;

//   if (data.status != ResultStatus.success) {
//     print(result.message);
//     Navigator.push(
//         context, MaterialPageRoute(builder: (context) => HomePage()));
//   }

//   ///TODO: use response data
// }
