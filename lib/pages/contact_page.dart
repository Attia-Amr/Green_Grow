import 'package:flutter/material.dart';
import 'company_chat_page.dart'; // تأكد من مسار الاستيراد الصحيح

class ContactCompaniesPage extends StatefulWidget {
  const ContactCompaniesPage({super.key});

  @override
  _ContactCompaniesPageState createState() => _ContactCompaniesPageState();
}

class _ContactCompaniesPageState extends State<ContactCompaniesPage> {
  final List<Map<String, dynamic>> companies = [
    {
      'name': 'GreenFarm Supplies',
      'phone': '0100-123-4567',
      'location': 'Minya, Egypt',
      'isOnline': true,
      'image': 'images/GreenFarm Supplies.jpg',
      'services': ['Fertilizers', 'Seeds'],
    },
    {
      'name': 'AgriGrow Egypt',
      'phone': '0101-987-6543',
      'location': 'Cairo, Egypt',
      'isOnline': false,
      'image': 'images/AgriGrow Egypt.jpg',
      'services': ['Irrigation', 'Consultancy'],
    },
    {
      'name': 'FarmTech Solutions',
      'phone': '0102-456-7890',
      'location': 'Alexandria, Egypt',
      'isOnline': true,
      'image': 'images/FarmTech Solutions.jpg',
      'services': ['Smart Farming', 'Fertilizers'],
    },
    {
      'name': 'AgriProducers',
      'phone': '0103-987-6543',
      'location': 'Giza, Egypt',
      'isOnline': true,
      'image': 'images/AgriProducers.jpg',
      'services': ['Seeds', 'Irrigation'],
    },
    {
      'name': 'AgriConnect',
      'phone': '0104-321-9876',
      'location': 'Tanta, Egypt',
      'isOnline': false,
      'image': 'images/AgriConnect.jpg',
      'services': ['Consultancy', 'Smart Farming'],
    },
    {
      'name': 'GreenLeaf Solutions',
      'phone': '0105-654-3210',
      'location': 'Aswan, Egypt',
      'isOnline': true,
      'image': 'images/GreenLeaf Solutions.jpg',
      'services': ['Fertilizers', 'Irrigation'],
    },
    {
      'name': 'AgriGrow Plus',
      'phone': '0106-456-7890',
      'location': 'Luxor, Egypt',
      'isOnline': false,
      'image': 'images/AgriGrow Plus.jpg',
      'services': ['Smart Farming', 'Seeds'],
    },
    {
      'name': 'FarmSense Egypt',
      'phone': '0107-321-6549',
      'location': 'Damanhur, Egypt',
      'isOnline': true,
      'image': 'images/FarmSense Egypt.jpg',
      'services': ['Irrigation', 'Consultancy'],
    },
    {
      'name': 'AgriMax Solutions',
      'phone': '0108-567-4321',
      'location': 'Mansoura, Egypt',
      'isOnline': false,
      'image': 'images/AgriMax Solutions.jpg',
      'services': ['Fertilizers', 'Smart Farming'],
    },
    {
      'name': 'FarmLink Egypt',
      'phone': '0109-654-1230',
      'location': 'Beni Suef, Egypt',
      'isOnline': true,
      'image': 'images/FarmLink Egypt.jpg',
      'services': ['Seeds', 'Irrigation'],
    },
    {
      'name': 'AgriFuture',
      'phone': '0110-987-5432',
      'location': 'Cairo, Egypt',
      'isOnline': true,
      'image': 'images/AgriFuture.jpg',
      'services': ['Consultancy', 'Smart Farming'],
    },
    {
      'name': 'EcoFarm Solutions',
      'phone': '0111-321-7890',
      'location': 'Alexandria, Egypt',
      'isOnline': false,
      'image': 'images/EcoFarm Solutions.jpg',
      'services': ['Fertilizers', 'Seeds'],
    },
    {
      'name': 'FarmTech Innovations',
      'phone': '0112-987-4321',
      'location': 'Giza, Egypt',
      'isOnline': true,
      'image': 'images/FarmTech Innovations.jpg',
      'services': ['Smart Farming', 'Irrigation'],
    },
    {
      'name': 'AgriConsulting Egypt',
      'phone': '0113-654-9876',
      'location': 'Minya, Egypt',
      'isOnline': true,
      'image': 'images/AgriConsulting Egypt.jpg',
      'services': ['Consultancy', 'Seeds'],
    },
  ];

  String? selectedService;

  void _openChat(BuildContext context, String companyName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyChatPage(companyName: companyName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.white,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: const Text(
              'Companies',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                shadows: [
                  Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
                ],
              ),
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 15, 77, 48),
                  Color.fromARGB(255, 5, 14, 8),
                ],
                stops: [0.3, 1.0],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for companies...',
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedService,
                  hint: const Text('Select Service', style: TextStyle(color: Colors.black54)),
                  items: ['Fertilizers', 'Seeds', 'Irrigation', 'Consultancy', 'Smart Farming']
                      .map((service) => DropdownMenuItem<String>(
                            value: service,
                            child: Text(service),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedService = value;
                    });
                  },
                  icon: const Icon(Icons.filter_list, color: Colors.green),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Column(
                children: companies
                    .where((company) =>
                        selectedService == null ||
                        company['services'].contains(selectedService))
                    .map((company) {
                  final isOnline = company['isOnline'] ?? false;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4, // تصغير الظل قليلًا
                    shadowColor: Colors.grey.withOpacity(0.4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _openChat(context, company['name']),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20)),
                            child: Image.asset(
                              company['image'],
                              width: 120, // تصغير الصورة
                              height: 140, // تصغير الصورة
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12), // تصغير البادينج
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    company['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16), // خط أصغر
                                  ),
                                  const SizedBox(height: 4),
                                  Text('📍 ${company['location']}',
                                      style: const TextStyle(fontSize: 13)),
                                  Text('📞 ${company['phone']}',
                                      style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: isOnline ? Colors.green : Colors.red,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(isOnline ? 'Online' : 'Offline',
                                          style: const TextStyle(fontSize: 13)),
                                      const Spacer(),
                                      Icon(Icons.chat_bubble_outline,
                                          color: Colors.green, size: 20), // أيقونة الشات هنا
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
