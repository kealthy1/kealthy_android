import 'package:flutter/material.dart';

class ReturnRefundPolicyPage extends StatelessWidget {
  const ReturnRefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Color(0xFF273847),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Return and Refund Policy',
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Return and Refund Policy",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Last updated: December 18, 2024",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              "Thank you for shopping at Kealthy.",
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            const Text(
              "If, for any reason, You are not completely satisfied with a purchase We invite You to review our policy on refunds and returns.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            const Text(
              "The following terms are applicable for any products that You purchased with Us.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Interpretation and Definitions"),
            _buildSubsectionTitle("Interpretation"),
            const Text(
              "The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            _buildSubsectionTitle("Definitions"),
            _buildDefinition(
              "Application",
              "The software program provided by the Company downloaded by You on any electronic device, named Kealthy.",
            ),
            _buildDefinition(
              "Company",
              "COTOLORE ENTERPRISES LLP, located at Floor No.: 1, Building No./Flat No.: 15/293 - C, Name Of Premises/Building: Peringala, Road/Street: Muriyankara-Pinarmunda Milma Road, City/Town/Village: Kunnathunad, District: Ernakulam, State: Kerala, PIN Code: 683565.",
            ),
            _buildDefinition(
              "Goods",
              "The items offered for sale on the Service.",
            ),
            _buildDefinition(
              "Orders",
              "A request by You to purchase Goods from Us.",
            ),
            _buildDefinition(
              "Service",
              "The Application.",
            ),
            _buildDefinition(
              "You",
              "The individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.",
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Your Order Cancellation Rights"),
            const Text(
              "You are entitled to cancel Your Order within 7 days without giving any reason for doing so.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            const Text(
              "The deadline for cancelling an Order is 7 days from the date on which You received the Goods or on which a third party you have appointed, who is not the carrier, takes possession of the product delivered.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            const Text(
              "In order to exercise Your right of cancellation, You must inform Us of your decision by means of a clear statement. You can inform us of your decision by:",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            _buildContactDetail("By email", "project@kealthy.com"),
            const SizedBox(height: 10),
            const Text(
              "We will reimburse You no later than 14 days from the day on which We receive the returned Goods. We will use the same means of payment as You used for the Order, and You will not incur any fees for such reimbursement.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Conditions for Returns"),
            const Text(
              "In order for the Goods to be eligible for a return, please make sure that:",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint("The Goods were purchased in the last 7 days."),
            _buildBulletPoint("The Goods are in the original packaging."),
            const SizedBox(height: 10),
            const Text(
              "The following Goods cannot be returned:",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                "The supply of Goods made to Your specifications or clearly personalized."),
            _buildBulletPoint(
                "The supply of Goods which according to their nature are not suitable to be returned, deteriorate rapidly or where the date of expiry is over."),
            _buildBulletPoint(
                "The supply of Goods which are not suitable for return due to health protection or hygiene reasons and were unsealed after delivery."),
            _buildBulletPoint(
                "The supply of Goods which are, after delivery, according to their nature, inseparably mixed with other items."),
            const SizedBox(height: 10),
            const Text(
              "We reserve the right to refuse returns of any merchandise that does not meet the above return conditions in our sole discretion.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            const Text(
              "Only regular priced Goods may be refunded. Unfortunately, Goods on sale cannot be refunded. This exclusion may not apply to You if it is not permitted by applicable law.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Returning Goods"),
            const Text(
              "You are responsible for the cost and risk of returning the Goods to Us. You should send the Goods at the following address:",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            const Text(
              "Floor No.: 1\nBuilding No./Flat No.: 15/293 - C\nName Of Premises/Building: Peringala\nRoad/Street: Muriyankara-Pinarmunda Milma Road\nCity/Town/Village: Kunnathunad\nDistrict: Ernakulam\nState: Kerala\nPIN Code: 683565",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            const Text(
              "We cannot be held responsible for Goods damaged or lost in return shipment. Therefore, We recommend an insured and trackable mail service. We are unable to issue a refund without actual receipt of the Goods or proof of received return delivery.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Gifts"),
            const Text(
              "If the Goods were marked as a gift when purchased and then shipped directly to you, You'll receive a gift credit for the value of your return. Once the returned product is received, a gift certificate will be mailed to You.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            const Text(
              "If the Goods weren't marked as a gift when purchased, or the gift giver had the Order shipped to themselves to give it to You later, We will send the refund to the gift giver.",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Contact Us"),
            const Text(
              "If you have any questions about our Returns and Refunds Policy, please contact us:",
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            _buildContactDetail("By email", "project@kealthy.com"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildDefinition(String term, String definition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontSize: 14, fontFamily: 'Poppins', color: Colors.black),
          children: [
            TextSpan(
              text: "$term: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: definition),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetail(String method, String detail) {
    return Row(
      children: [
        Text(
          "$method: ",
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins'),
        ),
        Text(
          detail,
          style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
        ),
      ],
    );
  }
}
