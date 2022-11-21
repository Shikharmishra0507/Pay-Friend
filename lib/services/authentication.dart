import 'package:firebase_auth/firebase_auth.dart';
class Authentication{
  
  FirebaseAuth auth=FirebaseAuth.instance;
  Stream<User?> get isAuthenticated{
    return auth.authStateChanges();
  }
  Future<void> signOut () async{
    await auth.signOut();
  }
  

}