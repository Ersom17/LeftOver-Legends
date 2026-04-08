import 'package:appwrite/appwrite.dart';
import 'appwrite_constants.dart';

final Client client = Client()
    .setEndpoint(AppwriteConstants.endpoint)
    .setProject(AppwriteConstants.projectId);

final Account account = Account(client);
final Databases databases = Databases(client);