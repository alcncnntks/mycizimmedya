import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedPage extends StatefulWidget {
  final String userId;
  final String token;

  FeedPage({required this.userId, required this.token});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<dynamic> _feedData = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFeedData();
  }

  Future<void> _fetchFeedData() async {
    try {
      final response = await http.post(
        Uri.parse('https://cizimmedya.com/chat/api/feed/index.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': widget.userId,
          'token': widget.token,
          'lang': 'tr',
          'page': '1',  // Sayfa numarasını 1 olarak gönderiyoruz, ihtiyaç halinde değiştirilebilir.
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true && responseBody['result'] != null) {
          setState(() {
            _feedData = responseBody['result']['feed'];
            _isLoading = false;
            _hasError = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = responseBody['message'] ?? 'Bilinmeyen bir hata oluştu';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Sunucu hatası: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Veriler yüklenirken hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text('Veriler yüklenirken hata oluştu: $_errorMessage'))
          : ListView.builder(
        itemCount: _feedData.length,
        itemBuilder: (context, index) {
          final item = _feedData[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(item['userImage']),
              ),
              title: Text(item['userName']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['userRole']),
                  SizedBox(height: 8.0),
                  Text(item['content']),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.comment),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
