// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

final _apiEndPoint = dotenv.env["API_ENDPOINT"];
/* start of user routes */
final USER_LOGIN_ROUTE = '$_apiEndPoint/user/login';
final USER_REGISTER_ROUTE = '$_apiEndPoint/user/registration';
final USER_PROFILE_PICTURE_UPLOAD_ROUTE = '$_apiEndPoint/data/uploadProfilePicture';
final USER_PROFILE_PICTURE_GET_ROUTE = '$_apiEndPoint/data/getProfilePicture';
final USER_UPDATE_USER_DATA = '$_apiEndPoint/user/updateUserData';
final USER_ACCOUNT_VERIFY_ROUTE = '$_apiEndPoint/user/sendVerificationLink';
final USER_PASSWORD_RESET_ROUTE = '$_apiEndPoint/user/sendPasswordResetLink';
/* end of user routes */

/* start of todo_routes */
final TODO_ADD_ROUTE = '$_apiEndPoint/todo/addTodo';
final TODO_GET_ROUTE = '$_apiEndPoint/todo/getTodos';
/// Required todoId in params
final TODO_DELETE_ROUTE = '$_apiEndPoint/todo/deleteTodo';
final TODO_UPDATE_ROUTE = '$_apiEndPoint/todo/updateTodo';
/* end of todo_routes */

/*start of note routes */
final NOTE_ADD_ROUTE = '$_apiEndPoint/note/addNote';
final NOTE_GET_ROUTE = '$_apiEndPoint/note/getNotes';
final NOTE_UPDATE_ROUTE = '$_apiEndPoint/note/updateNote';
/// Required noteId in params
final NOTE_DELETE_ROUTE = '$_apiEndPoint/note/deleteNote';
/*end of note routes */
