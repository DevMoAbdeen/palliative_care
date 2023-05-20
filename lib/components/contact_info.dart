import 'package:flutter/material.dart';
import 'package:palliative_care/constants.dart';

class ContactInfoDoctor extends StatelessWidget {
  final IconData icon;
  final String text;
  final String value;

  const ContactInfoDoctor({Key? key, required this.icon, required this.text, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: kMainColorDark,
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

///////////////

class ContactInfoPatient extends StatelessWidget {
  final IconData icon;
  final String text;
  final String value;

  const ContactInfoPatient(
      {Key? key, required this.icon, required this.text, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListTile(
        leading: Icon(
          icon,
          size: 24,
          color: kMainColorDark,
        ),
        title: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
