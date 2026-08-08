import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getNotes();
    setState(() {
      notes = data;
      isLoading = false;
    });
  }

  Future<void> _deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    _refreshNotes();
  }

  void _showAddNoteSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ملاحظة سريعة جديدة 📝', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'اكتب ملاحظتك هنا...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    
                    await DatabaseHelper.instance.insertNote({
                      'title': titleController.text.trim(),
                      'content': contentController.text.trim(),
                      'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                    });

                    if (context.mounted) Navigator.pop(context);
                    _refreshNotes();
                  },
                  child: const Text('حفظ الملاحظة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('الملاحظات السريعة 📌', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(child: Text('لا توجد ملاحظات سريعة بعد.. ابدأ بإضافة ملاحظة! 💡', style: TextStyle(color: Colors.grey, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(note['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteNote(note['id']),
                              ),
                            ],
                          ),
                          if (note['content'].isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(note['content'], style: const TextStyle(fontSize: 15, color: Colors.black87)),
                          ],
                          const SizedBox(height: 12),
                          Text(note['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteSheet,
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}