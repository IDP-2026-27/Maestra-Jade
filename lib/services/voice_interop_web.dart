import 'dart:js_interop' as js;

@js.JS('speakBritishTeacher')
external void _jsSpeakBritishTeacher(js.JSString text);

@js.JS('stopTeacherSpeech')
external void _jsStopTeacherSpeech();

void jsSpeakBritishTeacher(String text) {
  _jsSpeakBritishTeacher(text.toJS);
}

void jsStopTeacherSpeech() {
  _jsStopTeacherSpeech();
}
