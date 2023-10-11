import 'package:beacon_project/home_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'constants/custom_field.dart';
import 'constants/string_constants.dart';
import 'constants/themes.dart';
class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 24, right: 24),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            slivers: [
              SliverFillRemaining(
                fillOverscroll: true,
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(ConstantStrings.registerText, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: CustomColors.primaryColor),),
                    const SizedBox(height: 20,),
                    Text(ConstantStrings.registerNameText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CustomColors.primaryColor),),
                    const SizedBox(height: 15,),
                    CustomField(label: ConstantStrings.registerLabelText, control: nameController, obs: false, hint: ConstantStrings.registerNameHintText),
                    const SizedBox(height: 25,),
                    Text(ConstantStrings.emailText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CustomColors.primaryColor),),
                    const SizedBox(height: 15,),
                    CustomField(label: ConstantStrings.emailLabelText, control: emailController, obs: false, hint: ConstantStrings.registerEmailHintText,),
                    const SizedBox(height: 25,),
                    Text(ConstantStrings.passwordText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CustomColors.primaryColor),),
                    const SizedBox(height: 15,),
                    CustomField(label: ConstantStrings.passwordText, control: passwordController, obs: true, hint: ConstantStrings.passwordHintText,),
                    const SizedBox(height: 25,),
                    Text(ConstantStrings.registerCityText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CustomColors.primaryColor),),
                    const SizedBox(height: 15,),
                    CustomField(label: ConstantStrings.registerCityText, control: cityController, obs: false, hint: ConstantStrings.registerCityHintText),
                    const SizedBox(height: 25,),

                    ValueListenableBuilder(valueListenable: isLoading, builder: (context, loading, child) {
                      return loading ? const Center(child: CircularProgressIndicator()) : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColors.circleColor,
                                    fixedSize: const Size(360, 50)
                                ),
                                onPressed: () async {
                                  if (emailController.text.isEmpty ||
                                      passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text(ConstantStrings.snackText),
                                      backgroundColor: Colors.red,));
                                  } else if (passwordController.text.length < 7) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text(
                                          "Please enter a password with more than 6 characters"),
                                      backgroundColor: Colors.red,));
                                  }
                                  else {
                                    isLoading.value = !isLoading.value;
                                    Future.delayed(const Duration(seconds: 2), () {
                                      isLoading.value = !isLoading.value;
                                    });
                                    await AuthService().register(
                                        emailController.text, passwordController.text, context);
                                    if(context.mounted) {
                                      Navigator.pushAndRemoveUntil(
                                          context, MaterialPageRoute(
                                          builder: (context) => HomeScreen()), (
                                          route) => false);
                                    }
                                  }
                                }, child: const Text(ConstantStrings.registerText)),
                          ),
                        ],
                      );
                    }
                    ),
                    const SizedBox(height: 20,),

                    Center(
                      child: TextButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(ConstantStrings.alreadyAccountText, style: TextStyle(color: Colors.grey, fontSize: 12),),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(ConstantStrings.loginText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, ),),
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
