import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminProvider>().loadUsers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAdminDialog(context),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading && adminProvider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${adminProvider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      adminProvider.clearError();
                      adminProvider.loadUsers();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (adminProvider.users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No users found'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adminProvider.users.length,
            itemBuilder: (context, index) {
              final user = adminProvider.users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isAdmin ? Colors.red.shade100 : Colors.blue.shade100,
                    child: Icon(
                      user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: user.isAdmin ? Colors.red.shade700 : Colors.blue.shade700,
                    ),
                  ),
                  title: Text(
                    user.name.isEmpty ? 'No Name' : user.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      if (user.isAdmin)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ADMIN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: user.id != null ? PopupMenuButton<String>(
                    onSelected: (value) => _handleUserAction(context, value, user),
                    itemBuilder: (context) => [
                      if (!user.isAdmin)
                        const PopupMenuItem(
                          value: 'make_admin',
                          child: ListTile(
                            leading: Icon(Icons.admin_panel_settings),
                            title: Text('Make Admin'),
                          ),
                        ),
                      if (user.isAdmin)
                        const PopupMenuItem(
                          value: 'remove_admin',
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text('Remove Admin'),
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete User', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ) : const Icon(Icons.error, color: Colors.red),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleUserAction(BuildContext context, String action, User user) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    // Check if user ID is valid
    if (user.id == null || user.id!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot perform action: Invalid user ID')),
        );
      }
      return;
    }
    
    switch (action) {
      case 'make_admin':
        final confirmed = await _showConfirmDialog(
          context,
          'Make Admin',
          'Are you sure you want to give admin privileges to ${user.name.isEmpty ? user.email : user.name}?',
        );
        if (confirmed) {
          final success = await adminProvider.makeUserAdmin(user.id!);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User promoted to admin successfully')),
            );
          }
        }
        break;
        
      case 'remove_admin':
        final confirmed = await _showConfirmDialog(
          context,
          'Remove Admin',
          'Are you sure you want to remove admin privileges from ${user.name.isEmpty ? user.email : user.name}?',
        );
        if (confirmed) {
          final success = await adminProvider.removeAdminPrivileges(user.id!);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Admin privileges removed successfully')),
            );
          }
        }
        break;
        
      case 'delete':
        final confirmed = await _showConfirmDialog(
          context,
          'Delete User',
          'Are you sure you want to delete ${user.name.isEmpty ? user.email : user.name}? This will also delete all their data and cannot be undone.',
        );
        if (confirmed) {
          if (user.id != null) {
            final success = await adminProvider.deleteUser(user.id!);
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cannot delete user: Invalid user ID')),
              );
            }
          }
        }
        break;
    }
  }

  Future<bool> _showConfirmDialog(BuildContext context, String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showCreateAdminDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Admin User'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                final success = await context.read<AdminProvider>().createAdmin(
                  nameController.text.trim(),
                  emailController.text.trim(),
                  passwordController.text,
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Admin user created successfully')),
                  );
                  context.read<AdminProvider>().loadUsers();
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
