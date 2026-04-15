import 'package:flutter/material.dart';
import 'package:catering_dapur_bu_mon/services/dio_helper.dart';
import 'package:dio/dio.dart';

class TestConnectionPage extends StatefulWidget {
  const TestConnectionPage({super.key});

  @override
  State<TestConnectionPage> createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  String _status = 'Belum di test';
  String _detail = '';
  bool _loading = false;

  Future<void> testConnection() async {
    setState(() {
      _loading = true;
      _status = 'Testing...';
    });

    try {
      // Test endpoint sederhana
      final response = await DioHelper.dio.get('/test_connection.php');
      
      setState(() {
        _status = '✅ Berhasil!';
        _detail = 'Status: ${response.statusCode}\nData: ${response.data}';
      });
      
      print('SUCCESS: ${response.data}');
    } on DioException catch (e) {
      String errorMsg = '';
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMsg = 'Connection timeout - Server tidak merespon';
          break;
        case DioExceptionType.receiveTimeout:
          errorMsg = 'Receive timeout - Server terlalu lama merespon';
          break;
        case DioExceptionType.connectionError:
          errorMsg = 'Connection error - Tidak bisa terhubung ke server\n'
                     'Pastikan:\n'
                     '• HP dan komputer 1 WiFi\n'
                     '• Server Apache running\n'
                     '• IP benar: 192.168.0.23\n'
                     '• Firewall tidak memblokir';
          break;
        default:
          errorMsg = e.message ?? 'Unknown error';
      }
      
      setState(() {
        _status = '❌ Gagal';
        _detail = 'Error: $errorMsg\n\nDetail: ${e.toString()}';
      });
      
      print('ERROR: ${e.type} - ${e.message}');
    } catch (e) {
      setState(() {
        _status = '❌ Error';
        _detail = 'Error: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Koneksi API'),
        backgroundColor: const Color(0xFFD05122),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Konfigurasi Server:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Base URL: ${DioHelper.baseUrl}'),
                  Text('IP Server: 192.168.0.23'),
                  const SizedBox(height: 8),
                  const Text(
                    'Pastikan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('✓ HP dan komputer 1 WiFi'),
                  const Text('✓ Apache running di Linux'),
                  const Text('✓ Firewall tidak memblokir port 80'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD05122),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Koneksi'),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _status.contains('Berhasil') 
                    ? Colors.green[50] 
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _status.contains('Berhasil') 
                      ? Colors.green 
                      : Colors.red,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $_status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _status.contains('Berhasil') 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _detail,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}