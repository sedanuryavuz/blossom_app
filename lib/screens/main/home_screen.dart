import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'img_slider.dart';
import 'product_list.dart';
import 'product_details.dart';
import 'package:blossom_app/services/functions.dart';

class AnaEkran extends StatefulWidget {
  @override
  _AnaEkranState createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> categories = [];
  List<DocumentSnapshot> womenProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchWomenProducts();
  }

  void _fetchCategories() async {
    QuerySnapshot querySnapshot = await _firestore.collection('category').get();
    setState(() {
      categories = querySnapshot.docs
          .map((doc) => doc['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    });
  }

  void _fetchWomenProducts() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('products')
        .where('category', isEqualTo: 'Kadın')
        .limit(3)
        .get();
    setState(() {
      womenProducts = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'blossom',
          style: TextStyle(fontWeight: FontWeight.w400, fontFamily: "Nunito"),
        ),
        backgroundColor: Colors.pink.shade100,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SearchBarWidget(),
            ),
            const SizedBox(height: 20),
            Image.asset("assets/images/img.png"),
            const SizedBox(height: 20),
            kategoriButonu(context),
            const SizedBox(height: 20),
            Container(
              height: 250.0,
              child: const ImgSlider(),
            ),
            const SizedBox(height: 20),
            miniIcon(), // Mini icons
            const SizedBox(height: 20),
            yatayKaydirmaKutular(),
            const SizedBox(height: 20),
            Image.asset("assets/images/banner.jpg"),
            const SizedBox(height: 20),
            fourRectangles2(),
          ],
        ),
      ),
    );
  }

  Widget miniIcon() {
    List<Map<String, dynamic>> items = [
      {"icon": Icons.local_offer, "text": "İndirim"},
      {"icon": Icons.card_giftcard, "text": "Hediye"},
      {"icon": Icons.shopping_bag, "text": "Kıyafet"},
      {"icon": Icons.phone_android, "text": "Telefonlar"},
      {"icon": Icons.face, "text": "Kozmetik"},
      {"icon": Icons.category, "text": "Hepsi"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 45),
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 243, 215, 213),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      items[index]["icon"],
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  items[index]["text"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.pink.shade100,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget yatayKaydirmaKutular() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: womenProducts.map((product) {
          return Padding(
            padding: const EdgeInsets.all(7.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 45),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(productId: product.id),
                    ),
                  );
                },
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        product['image'],
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    //  const SizedBox(height: 5),
                      Text(
                        product['name'],
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '\$${product['price']}',
                        style: TextStyle(
                          color: Colors.pink.shade100,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget kategoriButonu(BuildContext context) {
    if (categories.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return buildButton(context, category);
        }).toList(),
      ),
    );
  }

  Widget buildButton(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.pink.shade100,
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductListScreen(category: title),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Nunito3",
          ),
        ),
      ),
    );
  }
}

Widget fourRectangles2() {
  List<String> imagePaths = [
    'assets/images/k1.png',
    'assets/images/k2.png',
    'assets/images/k3.png',
    'assets/images/k4.png'
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3.0),
    child: GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.0,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePaths[index],
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
        );
      },
    ),
  );
}

class SearchBarWidget extends StatefulWidget {
  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Ara...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      onSubmitted: (query) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListScreen(category: query),
          ),
        );
      },
    );
  }
}
