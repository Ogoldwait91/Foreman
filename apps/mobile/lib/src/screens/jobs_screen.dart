import "package:flutter/material.dart";
import "../theme.dart";
import "../data/app_store.dart";
import "../models/job.dart";
import "job_detail_screen.dart";

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore();
    return Scaffold(
      backgroundColor: ForemanColors.navy,
      appBar: AppBar(
        title: const Text("Jobs"),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final ctrl = TextEditingController();
              await showDialog(context: context, builder: (ctx) => AlertDialog(
                title: const Text("New job"),
                content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: "Job name")),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                  ElevatedButton(onPressed: () { if (ctrl.text.trim().isNotEmpty) AppStore().addJob(ctrl.text.trim()); Navigator.pop(ctx); }, child: const Text("Create")),
                ],
              ));
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: store.jobs.length,
        itemBuilder: (_, i) {
          final j = store.jobs[i];
          return Card(
            child: ListTile(
              title: Text(j.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: j.id))),
            ),
          );
        },
      ),
    );
  }
}
