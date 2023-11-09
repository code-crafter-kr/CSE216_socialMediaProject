import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:knights/models/idea.dart';
import 'package:knights/models/User.dart';
import 'package:knights/models/DetailedPost.dart';

//const String userId = '1234567890abcdef1234567890abcdef';


// web function togetuser profile data
// View User
// /users/:id
// GET
// View a User’s Profile Page

// /// post
// Future<String> verifyLogin(String token) async{
//   developer.log('sending token to backend...');
//   var url = Uri.parse('https://team-knights.dokku.cse.lehigh.edu/login');
//   var headers = {"Accept":"application/json"};

// }




Future<User> fetchUsers(String userId, String sessionKey) async{
  developer.log('Making web request for user data...');
  var url = Uri.parse('http://10.0.2.2:8998/users/$userId?sessionKey=$sessionKey');
  var headers = {"Accept":"application/json"};
  // garbage user that gets returned if sopmething goes wrong
  User garb = User(mId: "", mUsername: 'garbage', mEmail: 'nonExistent', mNote: 'garbage');

  var response = await http.get(url, headers: headers);

  if(response.statusCode == 200){
    final User returnData;

    var res = jsonDecode(response.body);
    developer.log('json decode: $res');
    developer.log('resmdata: ${res['mData']}');
    if(res['mData'] is Map){
      returnData = User.fromJson(res['mData'] as Map<String,dynamic>);
    } else {
      developer.log('ERROR: Unexpected json response type (was not user). Using garb');
      returnData = garb;
    }

        developer.log('$returnData');
        return returnData;

  } else{
    throw Exception('Did not receive success status code from request.');
  }
}


/// GET request for detailed view of post
Future<DetailedPost> fetchDetailedPost(int mId) async{
  developer.log('Making web request for detailed post data...');
  var url = Uri.parse('https://team-knights.dokku.cse.lehigh.edu/ideas/$mId');
  var headers = {"Accept":"application/json"};
  // garbage DetailedPost that gets returned if sopmething goes wrong
  

  var response = await http.get(url, headers: headers);

  if(response.statusCode == 200){
    final DetailedPost returnData;

    var res = jsonDecode(response.body);
    developer.log('json decode: $res');
    developer.log('resmdata: ${res['mData']}');
    if(res['mData'] is Map){
      returnData = DetailedPost.fromJson(res['mData'] as Map<String, dynamic>);
    } else {
      developer.log('ERROR: Unexpected json response type (was not ideas/id). Check web_requests and that proper data is passed.');
      returnData = DetailedPost(mId: -1, mContent: "error", mLikeCount: 0, mUserId: "notValid123", mPosterUserName: "DNE123");
    }

        developer.log('$returnData');
        return returnData;

  } else{
    throw Exception('Did not receive success status code from request.');
  }
}





///Web Function to send put request to respective idea ID, and *decrement* mLikeCount
Future<bool> onDislikeButtonTapped(int id) async{
  ///Can safely ignore isLiked
  bool isLiked = true;

    developer.log('Making web request...');
    var url = Uri.parse('https://team-knights.dokku.cse.lehigh.edu/ideas/$id');
    var headers = {"Accept": "application/json"};
    var body = {'mLikeIncrement': '-1'};

    var response = await http.put(url, headers: headers, body: jsonEncode(body));

    developer.log('Response status: ${response.statusCode}');
    developer.log('Response headers: ${response.headers}');
    developer.log('Response body: ${response.body}');
    developer.log(await http.read(url));


    return !isLiked;
  }

  ///Web Function to send put request to respective idea ID, and *increment* mLikeCount    
  Future<bool> onLikeButtonTapped(int id) async{
    bool isLiked = true;


    developer.log('Making web request...');
    var url = Uri.parse('https://team-knights.dokku.cse.lehigh.edu/ideas/$id');
    var headers = {"Accept": "application/json"};
    var body = {'mLikeIncrement': '1'};

    var response = await http.put(url, headers: headers, body: jsonEncode(body));

    developer.log('Response status: ${response.statusCode}');
    developer.log('Response headers: ${response.headers}');
    developer.log('Response body: ${response.body}');
    developer.log(await http.read(url));

    return !isLiked;
  }

  ///Web Function to send post request to dokku backend. Creates idea with userText
  Future<String> postIdeas(String userText) async{
      developer.log('Making web request...');
      var url = Uri.parse('https://team-knights.dokku.cse.lehigh.edu/ideas');
      var headers = {"Accept": "application/json"};
      var body = {'mContent': userText};

      var response = await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200){
        developer.log('response headers: ${response.headers}');
        developer.log('response body: ${response.body}');

      return userText;
        
      }
      else{
        ///If the server did not return a 200 OK response,
        ///then throw an exception.
        throw Exception('Did not receive success status(200) code from request.');
      }
  }


    ///This web function fetches json data from dokku, and then 
    ///parses each json object into an idea object(model)
    Future<List<Idea>> fetchIdeas() async{
      developer.log('Making web request...');
      var url = Uri.parse('https://team-knights.dokku.cse.lehigh.edu/ideas');
      var headers = {"Accept": "application/json"};

      var response = await http.get(url, headers: headers);

      

      if (response.statusCode == 200){
        final List<Idea> returnData;
        
        var res = jsonDecode(response.body);
        developer.log('json decode: $res');
        developer.log('resmdata: ${res['mData']}');
        
        if(res['mData'] is List){
          //dynamic allows for a types to be inferred during runtime, and can be changed to different types
          returnData = (res['mData'] as List<dynamic>).map((x) => Idea.fromJson(x)).toList();
        }
        else if(res is Map){
          returnData = <Idea>[Idea.fromJson(res['mData'] as Map<String,dynamic>)];
        }else{
          developer.log('ERROR: Unexpected json response type (was not a List or Map).');
          returnData = List.empty();
        }

        developer.log('$returnData');
        return returnData;
      } 
      else{
        ///If the server did not return a 200 OK response, then throw an exception.
        throw Exception('Did not receive success status code from request.');
      }

    }


    ///This web function is similar to fetchIdeas, except it is modified to
    ///accept a http.Client as a parameter. This is done so we can test the web function
    ///with a mock http request as done in message_page_test.dart
    Future<List<Idea>> fetchIdeasTest(http.Client client) async{
      developer.log('Making web request...');
      var url = Uri.parse('https://team-knights.dokku.cse.lehigh.edu/ideas');
      var headers = {"Accept": "application/json"};

      var response = await client.get(url, headers: headers);

      

      if (response.statusCode == 200){
        final List<Idea> returnData;
        
        var res = jsonDecode(response.body);
        developer.log('json decode: $res');
        developer.log('resmdata: ${res['mData']}');
        
        if(res['mData'] is List){
          //dynamic allows for a types to be inferred during runtime, and can be changed to different types
          returnData = (res['mData'] as List<dynamic>).map((x) => Idea.fromJson(x)).toList();
        }
        else if(res is Map){
          returnData = <Idea>[Idea.fromJson(res['mData'] as Map<String,dynamic>)];
        }else{
          developer.log('ERROR: Unexpected json response type (was not a List or Map).');
          returnData = List.empty();
        }

        developer.log('$returnData');
        return returnData;
      } 
      else{
        ///If the server did not return a 200 OK response,
        throw Exception('Did not receive success status code from request.');
      }

    }