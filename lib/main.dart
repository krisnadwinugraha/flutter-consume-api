import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warga App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WargaListScreen(),
    );
  }
}

class WargaListScreen extends StatefulWidget {
  @override
  _WargaListScreenState createState() => _WargaListScreenState();
}

class _WargaListScreenState extends State<WargaListScreen> {
  Future<List<dynamic>> _wargaData = Future.value([]);

  @override
  void initState() {
    super.initState();
    _fetchWargaData();
  }

  Future<void> _fetchWargaData() async {
    final url = Uri.parse('http://10.0.2.2:5000/warga');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _wargaData = Future.value(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to fetch warga data');
    }
  }

  Future<void> createWarga(Map<String, dynamic> wargaData) async {
    final url = Uri.parse('http://10.0.2.2:5000/warga');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(wargaData),
    );

    if (response.statusCode == 201) {
      // Successful creation
      print('Warga created successfully');
      _fetchWargaData(); // Refresh the warga data after creation
    } else {
      // Handle error
      print('Failed to create warga. Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warga List'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _wargaData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> wargaList = snapshot.data as List<dynamic>;
            return ListView.builder(
              itemCount: wargaList.length,
              itemBuilder: (context, index) {
                var warga = wargaList[index];
                return ListTile(
                  title: Text(warga['nama']),
                  subtitle: Text(warga['alamat']),
                  trailing: Icon(Icons.more_vert),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Map<String, dynamic> wargaData = {
            'nama': 'John Doe',
            'nik': '1234567890',
            'tempat_lahir': 'Jakarta',
            'tanggal_lahir': '1990-01-01',
            'alamat': 'Jl. ABC No. 123',
            'pekerjaan': 'Engineer',
          };
          createWarga(wargaData);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
