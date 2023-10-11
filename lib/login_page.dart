import 'package:beacon_project/home_screen.dart';
import 'package:beacon_project/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'constants/custom_field.dart';
import 'constants/string_constants.dart';
import 'constants/themes.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final ValueNotifier<bool> isLoadingGoogle = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 31.0, left: 24, right: 24, bottom: 12),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              slivers: [
                SliverFillRemaining(
                    fillOverscroll: true,
                    hasScrollBody: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ConstantStrings.loginText, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),),
                        const SizedBox(height: 30,),
                        Text(ConstantStrings.emailText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        const SizedBox(height: 15,),
                        CustomField(label: ConstantStrings.emailLabelText, control: emailController, obs: false, hint: ConstantStrings.emailHintText,),
                        const SizedBox(height: 25,),
                        Text(ConstantStrings.passwordText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        const SizedBox(height: 15,),
                        CustomField(label: ConstantStrings.passwordText, control: passwordController, obs: true, hint: ConstantStrings.passwordHintText,),
                        const SizedBox(height: 25,),

                        ValueListenableBuilder(valueListenable: isLoading, builder: (context, loading, child){
                          return loading? const Center(child: CircularProgressIndicator()): Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(onPressed: () async{
                                  if(emailController.text.isEmpty || passwordController.text.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(ConstantStrings.snackText), backgroundColor: Colors.red,));
                                  } else {
                                    isLoading.value = !isLoading.value;
                                    Future.delayed(const Duration(seconds: 2), () {
                                      isLoading.value = !isLoading.value;
                                    });
                                    await AuthService().login(emailController.text, passwordController.text, context);
                                    if(FirebaseAuth.instance.currentUser != null){
                                      if(context.mounted) {
                                        Navigator.pushAndRemoveUntil(context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen()), (
                                                route) => false);
                                      }
                                    }
                                  }
                                },
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(367, 48)
                                  ),
                                  child: const Text(ConstantStrings.loginText, style: TextStyle(color: Colors.white),),
                                ),
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 20,),
                        Row(
                            children: const <Widget>[
                              Expanded(
                                  child: Divider(color: Colors.grey,)
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 4, right: 4),
                                child: Text(ConstantStrings.orText, style: TextStyle(color: Colors.grey),),
                              ),
                              Expanded(
                                  child: Divider(color: Colors.grey,)
                              ),
                            ]
                        ),

                        const SizedBox(height: 20,),

                        ValueListenableBuilder(valueListenable: isLoadingGoogle, builder: (context, loading, child){
                          return loading ? const Center(child: CircularProgressIndicator(),):Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async{
                                  isLoadingGoogle.value = !isLoadingGoogle.value;
                                  Future.delayed(const Duration(seconds: 2), () {
                                    isLoadingGoogle.value = !isLoadingGoogle.value;
                                  });
                                  await AuthService().signInWithGoogle();
                                  if(FirebaseAuth.instance.currentUser != null) {
                                    if (context.mounted) {
                                      Navigator.pushAndRemoveUntil(context,
                                          MaterialPageRoute(builder: (context) =>
                                              HomeScreen()), (route) => false);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                 padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(color: CustomColors.circle1Color)
                                  ),
                                ),
                                icon: Icon(Icons.facebook),
                                label: Text("Login with Google"),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 30,),
                      ],
                    )
                ),
              ],
            ),
          )
      ),
    );
  }
}
