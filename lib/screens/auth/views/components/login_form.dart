import 'package:flutter/material.dart';

import '../../../../constants.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool _obscurePassword = true;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _emailHasFocus = false;
  bool _passwordHasFocus = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      setState(() => _emailHasFocus = _emailFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordHasFocus = _passwordFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Email Label ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Email',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _emailHasFocus ? primaryColor : textSecondary,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
            ),
          ),

          // ── Email Field ──
          AnimatedContainer(
            duration: fastDuration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusMd),
              boxShadow: _emailHasFocus
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.emailController,
              focusNode: _emailFocus,
              validator: emailValidator.call,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'your@email.com',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: _emailHasFocus
                        ? primaryColor
                        : textTertiary,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
            ),
          ),

          const SizedBox(height: spaceLg),

          // ── Password Label ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Password',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _passwordHasFocus ? primaryColor : textSecondary,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
            ),
          ),

          // ── Password Field ──
          AnimatedContainer(
            duration: fastDuration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusMd),
              boxShadow: _passwordHasFocus
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.passwordController,
              focusNode: _passwordFocus,
              validator: passwordValidator.call,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: _passwordHasFocus
                        ? primaryColor
                        : textTertiary,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: AnimatedSwitcher(
                      duration: fastDuration,
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        key: ValueKey(_obscurePassword),
                        size: 20,
                        color: textTertiary,
                      ),
                    ),
                    splashRadius: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
