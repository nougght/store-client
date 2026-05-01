import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'models/auth.dart';
import 'main_page.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: authModel.isCodeSent
                ? authModel.isRegistration
                      ? RegisterForm()
                      : CodeInput()
                : LoginForm(),
          ),
        );
      },
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  var _isEmail = [true, false];

  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 80),
                Text(
                  _isEmail[1] ? "Введите почту" : "Введите номер телефона",
                  style: TextStyle(fontSize: 30),
                ),
                // SizedBox(height: 200),
                SizedBox(height: 40),
                ToggleButtons(
                  isSelected: _isEmail,
                  onPressed: (index) {
                    setState(() {
                      _isEmail = [index == 0, index == 1];
                    });
                  },
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  children: [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Телефон')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Почта')),
                  ],
                ),
                SizedBox(height: 20),
                _isEmail[1]
                    ? TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Почта',
                          hintText: 'example@gmail.com',
                          prefixIcon: Icon(Icons.email_rounded),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.contains('@') ? null : 'Некорректная почта',
                      )
                    : TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        // inputFormatters: [
                        //   FilteringTextInputFormatter.digitsOnly, // Только цифры
                        // ],
                        decoration: InputDecoration(
                          labelText: 'Номер телефона',
                          hintText: '+7 (XXX) XXX-XX-XX',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите номер телефона';
                          }
                          if (value.length < 11) {
                            return 'Номер слишком короткий';
                          }
                          return null;
                        },
                        // onChanged: (value) {
                        //   setState(() => _phone = value);
                        // },
                      ),
              ],
            ),
          ),
          ElevatedButton(onPressed: _submit, child: Text('Получить код')),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Отправка данных на бэкенд
      final recipient = _isEmail[1] ? _emailController.text : _phoneNumberController.text;
      final channel = _isEmail[1] ? "email" : "phone";
      bool res = await Provider.of<AuthModel>(context, listen: false).sendCode(recipient, channel);
      if (!res) {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при отправке кода' + Provider.of<AuthModel>(context, listen: false).error)));
      }
    }
  }
}

class CodeInput extends StatelessWidget {
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authModel = context.watch<AuthModel>();
    authModel.error == "" ? null : ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authModel.error)));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Код отправлен на ${authModel.code!.recipient}', style: TextStyle(fontSize: 30)),
        SizedBox(height: 40),
        TextField(
          style: TextStyle(fontSize: 35),
          controller: _codeController,
          decoration: InputDecoration(
            labelText: 'Код',
            hintText: 'XXXXXX',
            // prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          maxLength: 6,
          maxLines: 1,
        ),
        SizedBox(height: 160),
        ElevatedButton(
          onPressed: authModel.isLoading
              ? null
              : () async {
                  if (await authModel.verifyCode(_codeController.text)) {
                    final userId = await authModel.checkUser(authModel.code!.recipient ?? "");
                    if (userId != "") {
                      await authModel.login(userId);
                    }
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Неверный код')));
                  }

                  // if (isVerified)
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (_) => Text("Ok")),
                  //   );
                },
          child: Text('Подтвердить'),
        ),
      ],
    );
  }
}

class RegisterForm extends StatelessWidget {
  final nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authModel = context.watch<AuthModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Введите ваше имя', style: TextStyle(fontSize: 30)),
        SizedBox(height: 40),
        TextField(
          style: TextStyle(fontSize: 35),
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Имя',
            // hintText: 'XXXXXX',
            // prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          maxLength: 30,
          maxLines: 1,
        ),
        SizedBox(height: 160),
        ElevatedButton(
          onPressed: authModel.isLoading
              ? null
              : () async {
                  await authModel.register(nameController.text);
                },
          child: Text('Зарегистрироваться'),
        ),
      ],
    );
  }
}
