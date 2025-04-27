import 'package:flutter/material.dart';

class ImgSlider extends StatefulWidget {
  const ImgSlider({super.key});

  @override
  State<ImgSlider> createState() => _ImgSliderState();
}

class _ImgSliderState extends State<ImgSlider> {
  final PageController _pageController =
      PageController(); //sayfaları kontrol etmek için kullanılır
  int seciliSayfa = 0;

  final List<String> _images = [
    'assets/images/i1.png',
    'assets/images/i2.png',
    'assets/images/i3.png',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (details.delta.dx < 0) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  seciliSayfa = index;
                });
              },
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              height: 10.0,
              width: seciliSayfa == index ? 20.0 : 10.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color:
                    seciliSayfa == index ? Colors.pink.shade200 : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }
}
