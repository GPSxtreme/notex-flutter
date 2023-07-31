// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

final _apiEndPoint = dotenv.env["API_ENDPOINT"];
/* start of user routes */
final USER_LOGIN_ROUTE = '$_apiEndPoint/user/login';
final USER_REGISTER_ROUTE = '$_apiEndPoint/user/registration';
final USER_PROFILE_PICTURE_UPLOAD_ROUTE = '$_apiEndPoint/user/uploadProfilePicture';
final USER_PROFILE_PICTURE_GET_ROUTE = '$_apiEndPoint/user/getProfilePicture';
/* end of user routes */

/* start of todo_routes */
final TODO_ADD_ROUTE = '$_apiEndPoint/todo/addTodo';
final TODO_GET_ROUTE = '$_apiEndPoint/todo/getTodos';
/// Required todoId in params
final TODO_DELETE_ROUTE = '$_apiEndPoint/todo/deleteTodo';
/* end of todo_routes */

/*start of note routes */
final NOTE_ADD_ROUTE = '$_apiEndPoint/note/addNote';
final NOTE_GET_ROUTE = '$_apiEndPoint/note/getNotes';
/// Required noteId in params
final NOTE_DELETE_ROUTE = '$_apiEndPoint/note/deleteNote';