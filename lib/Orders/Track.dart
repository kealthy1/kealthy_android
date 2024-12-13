import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Orders/Appbar.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'provider.dart';

class OrderTrackingPage extends ConsumerStatefulWidget {
  final String orderid;
  final String DeliveryBoy;
  final String Address;
  final double Distance;
  final String phoneNumber;

  const OrderTrackingPage({
    required this.orderid,
    required this.Address,
    required this.DeliveryBoy,
    required this.Distance,
    required this.phoneNumber,
    super.key,
  });

  @override
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage> {
  final MapController _mapController = MapController();

  double calculateETA(double distanceInKm, double averageSpeedInKmPerHr) {
    if (distanceInKm <= 0) return 0;
    return (distanceInKm / averageSpeedInKmPerHr) * 100;
  }

  String getLast9Digits(String orderid) {
    if (orderid.length > 9) {
      return orderid.substring(orderid.length - 9);
    }
    return orderid;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final currentLocationAsyncValue =
        ref.watch(currentLocationProvider(widget.orderid));
    final destinationLocationAsyncValue =
        ref.watch(destinationLocationProvider(widget.orderid));
    final routeAsyncValue = ref.watch(routeProvider(widget.orderid));

    return Scaffold(
      appBar: ReusableAppBar(
        title: "Tracking Order #${getLast9Digits(widget.orderid)}",
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: currentLocationAsyncValue.when(
              data: (currentLocation) {
                if (currentLocation == null) {
                  return const Center(
                      child: Text("Current location not found"));
                }

                return destinationLocationAsyncValue.when(
                  data: (destinationLocation) {
                    if (destinationLocation == null) {
                      return const Center(
                          child: Text("Destination location not found"));
                    }
                    return routeAsyncValue.when(
                      data: (routePoints) {
                        const distanceCalculator = Distance();
                        final distanceInKm = distanceCalculator.as(
                            LengthUnit.Kilometer,
                            currentLocation,
                            destinationLocation);
                        const double averageSpeedInKmPerHr = 20.0;
                        calculateETA(distanceInKm, averageSpeedInKmPerHr);

                        return Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all &
                                      ~InteractiveFlag.rotate,
                                  debugMultiFingerGestureWinner: false,
                                  enableMultiFingerGestureRace: false,
                                ),
                                backgroundColor: Colors.transparent,
                                initialCenter: currentLocation,
                                initialZoom: 15.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: screenWidth * 0.15,
                                      height: screenHeight * 0.10,
                                      point: currentLocation,
                                      child: const Icon(
                                        Icons.circle,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                    ),
                                    Marker(
                                      width: screenWidth * 0.4,
                                      height: screenHeight * 0.05,
                                      point: destinationLocation,
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF273847),
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.house_fill,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: routePoints,
                                      strokeWidth: 2.0,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => Center(
                        child: LoadingAnimationWidget.discreteCircle(
                          color: Color(0xFF273847),
                          size: 50,
                        ),
                      ),
                      error: (error, stack) =>
                          Center(child: Text("Error: $error")),
                    );
                  },
                  loading: () => Center(
                    child: LoadingAnimationWidget.discreteCircle(
                      color: Color(0xFF273847),
                      size: 50,
                    ),
                  ),
                  error: (error, stack) => Center(child: Text("Error: $error")),
                );
              },
              loading: () => Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: Color(0xFF273847),
                  size: 50,
                ),
              ),
              error: (error, stack) => Center(child: Text("Error: $error")),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22.0),
                  topRight: Radius.circular(22.0),
                ),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08, vertical: screenWidth * 0.04),
              child: Column(
                children: [
                  currentLocationAsyncValue.when(
                    data: (currentLocation) {
                      if (currentLocation == null) {
                        return const SizedBox.shrink();
                      }
                      return destinationLocationAsyncValue.when(
                        data: (destinationLocation) {
                          if (destinationLocation == null) {
                            return const SizedBox.shrink();
                          }
                          const distanceCalculator = Distance();
                          final distanceInKm = distanceCalculator.as(
                              LengthUnit.Kilometer,
                              currentLocation,
                              destinationLocation);
                          const double averageSpeedInKmPerHr = 40.0;
                          final etaInMinutes =
                              calculateETA(distanceInKm, averageSpeedInKmPerHr);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Out for Delivery",
                                      style: TextStyle(
                                        fontFamily: "poppins",
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.Address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "poppins",
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(0xFF273847),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      (etaInMinutes < 1
                                              ? 1
                                              : etaInMinutes.ceil())
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      "mins",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => Center(
                          child: LoadingAnimationWidget.discreteCircle(
                            color: Color(0xFF273847),
                            size: 50,
                          ),
                        ),
                        error: (error, stack) =>
                            Center(child: Text("Error: $error")),
                      );
                    },
                    loading: () => Center(
                      child: LoadingAnimationWidget.discreteCircle(
                        color: Color(0xFF273847),
                        size: 50,
                      ),
                    ),
                    error: (error, stack) =>
                        Center(child: Text("Error: $error")),
                  ),
                  const Divider(
                    height: 20,
                    thickness: 3,
                    color: Colors.grey,
                  ),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: screenWidth * 0.10,
                          height: screenWidth * 0.10,
                          color: Color(0xFF273847),
                          alignment: Alignment.center,
                          child: Text(
                            widget.DeliveryBoy.isNotEmpty
                                ? widget.DeliveryBoy[0]
                                : '',
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.DeliveryBoy,
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade100),
                        icon: const Icon(
                          Icons.phone,
                          color: Color(0xFF273847),
                        ),
                        iconSize: screenWidth * 0.07,
                        onPressed: () async {
                          final phoneNumber = widget.phoneNumber;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: Colors.grey[300],
                                title: const Text(
                                  "Confirm Call",
                                  style: TextStyle(
                                      fontFamily: "poppins",
                                      overflow: TextOverflow.ellipsis),
                                ),
                                content: Text(
                                  "Do you want to call ${widget.DeliveryBoy} ?",
                                  style: TextStyle(
                                      fontFamily: "poppins",
                                      overflow: TextOverflow.ellipsis),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF273847),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await FlutterPhoneDirectCaller.callNumber(
                                          phoneNumber);
                                    },
                                    child: const Text(
                                      "Call Now",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
