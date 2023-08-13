// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

final _apiEndPoint = dotenv.env["API_ENDPOINT"];
/* start of user routes */
final USER_LOGIN_ROUTE = '$_apiEndPoint/user/login';
final USER_REGISTER_ROUTE = '$_apiEndPoint/user/registration';
final USER_PROFILE_PICTURE_UPLOAD_ROUTE = '$_apiEndPoint/user/uploadProfilePicture';
final USER_PROFILE_PICTURE_GET_ROUTE = '$_apiEndPoint/user/getProfilePicture';
final USER_UPDATE_USER_DATA = '$_apiEndPoint/user/updateUserData';
final USER_UPLOAD_PROFILE_PIC = '$_apiEndPoint/user/uploadProfilePicture';
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
final NOTE_UPDATE_ROUTE = '$_apiEndPoint/note/updateNote';
/// Required noteId in params
final NOTE_DELETE_ROUTE = '$_apiEndPoint/note/deleteNote';
/*end of note routes */
