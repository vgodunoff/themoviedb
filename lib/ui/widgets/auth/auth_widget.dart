import 'package:flutter/material.dart';
import 'package:themoviedb/ui/widgets/auth/auth_model.dart';

import '../../theme/app_button_style.dart';

/*
 TextField(
          controller: model?.loginTextController,
"это на самом деле не очень хорошая практика, потому что у нас есть четкий
контракт, что наша модель ChangeNotifier, то есть мы сюда добавляем какие-то изменения
и если они происходят, мы вызываем у нее notifyListeners, ее слушает наш виджет и обновляет
свои изменения.
а тут получается немного читерим и просто записываем всегда, вот здесь храним 
контроллер и записываем туда значения или можем изменить этот текстКонтроллер и 
значения там изменятся, при этом не будем прибегать к механизму notifyListeners.
так что это не хорошо, но пока что мы не говорим об архитектуре и о хороших решениях,
так что Джонфир здесь срезал угол, и делаем именно так"
         
*/

class AuthWidget extends StatefulWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login to your account'),
      ),
      body: const SingleChildScrollView(
        child: _HeaderWidget(),
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 16, color: Colors.black);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 25,
          ),
          // ignore: prefer_const_constructors
          _FormWidget(),
          const SizedBox(
            height: 25,
          ),
          const Text(
            'Чтобы пользоваться правкой и возможностями рейтинга TMDB, а также получить персональные рекомендации, необходимо войти в свою учётную запись. Если у вас нет учётной записи, её регистрация является бесплатной и простой. Нажмите здесь, чтобы начать.',
            style: textStyle,
          ),
          const SizedBox(
            height: 5,
          ),
          TextButton(
              onPressed: () {},
              style: AppButtonStyle.linkButton,
              child: const Text('Register')),
          const SizedBox(
            height: 25,
          ),
          const Text(
            'Если Вы зарегистрировались, но не получили письмо для подтверждения, нажмите здесь, чтобы отправить письмо повторно.',
            style: textStyle,
          ),
          const SizedBox(
            height: 5,
          ),
          TextButton(
              onPressed: () {},
              style: AppButtonStyle.linkButton,
              child: const Text('Verify email')),
        ],
      ),
    );
  }
}

/*
здесь нам нужно не просто добавить модельку. если мы добавим модельку - то мы
должны будем на нее подписаться
ну то есть если будет меняться , то мы например будем менять еррорТекст
а нам бы не хотелось менять всю форму
нам бы хотелось менять небольшую часть. а это кнопка логин, мы ее будем блокировать
когда отправляется запрос на авторизацию, чтобы не отправлялись такие же запросы 
по несколько раз, если пользователь будет несколько раз тыкать на кнопку  
    а также будем сообщение об ошибке показывать

*/
class _FormWidget extends StatelessWidget {
  const _FormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //используем метод read() - этот большой виджет мы изменять не будем
    // мы будем только получать здесь доступ
    final model = AuthProvider.read(context)?.model;

    const textStyle = TextStyle(fontSize: 16, color: Color(0xFF212529));
    const textFieldDecorator = InputDecoration(
        border: OutlineInputBorder(),
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10));
    //final errorText = this.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        const _ErrorMessageWidget(),
        const Text(
          'Username',
          style: textStyle,
        ),
        // ignore: prefer_const_constructors
        SizedBox(height: 5),
        // ignore: prefer_const_constructors
        TextField(
          controller: model?.loginTextController,
          decoration: textFieldDecorator,
        ),
        const SizedBox(height: 25),
        const Text(
          'Password',
          style: textStyle,
        ),
        // ignore: prefer_const_constructors
        const SizedBox(height: 5),
        // ignore: prefer_const_constructors
        TextField(
          controller: model?.passwordTextController,
          obscureText: true,
          decoration: textFieldDecorator,
        ),
        const SizedBox(
          height: 25,
        ),
        Row(
          children: [
            const _AuthButtonWidget(),
            const SizedBox(
              width: 30,
            ),
            TextButton(
                onPressed: () {},
                style: AppButtonStyle.linkButton,
                child: const Text('Reset password'))
          ],
        )
      ],
    );
  }
}

class _AuthButtonWidget extends StatelessWidget {
  const _AuthButtonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color color = Color(0XFF01B4E4);
    //model - watch чтобы менялась тоже кнопочка
    final model = AuthProvider.watch(context)?.model;
    final onPressed =
        model?.canStartAuth == true ? () => model?.auth(context) : null;
    final child = model?.isAuthProgress == true
        ? const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : const Text('Login');
    return ElevatedButton(
      // onPressed: _auth
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.white),
        backgroundColor: MaterialStateProperty.all(color),
        textStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
      ),
      child: child,
    );
  }
}

//сообщение об ошибке показывать
class _ErrorMessageWidget extends StatelessWidget {
  const _ErrorMessageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorMessage = AuthProvider.watch(context)?.model.errorMessage;
    if (errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        errorMessage,
        style: const TextStyle(fontSize: 17, color: Colors.red),
      ),
    );
  }
}
