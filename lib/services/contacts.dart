import 'package:contacts_service/contacts_service.dart';

class Contacts{
    Future<List<Contact>> getContacts()async{
      List<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
      return contacts;
    }
    Future<List<Item>> requiredPhoneNumbers() async{
      List<Item>_phones=[];
      List<Contact>_contacts=await getContacts();
      _contacts.forEach((element) {
        if(element.phones!=null){

          element.phones!.forEach((phone) {
            _phones.add(phone);
          });
        }
      });
      return _phones;
    }
}