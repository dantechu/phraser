import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// An asset (e.g. image/animation) bundled along in [package] at [path].
class PackagedAsset {
  /// The path of the asset in [package].
  final String path;

  /// [package] which contains the asset.
  final String? package;

  const PackagedAsset({required this.path, this.package});
}

/// Provides a interface to load packaged assets.
class AssetProvider {
  /// Returns an [SvgPicture] that shows [asset].
  static SvgPicture svgPicture(
    PackagedAsset asset, {
    double? dimension,
    Color? color,
  }) {
    return SvgPicture.asset(
      asset.path,
      package: asset.package,
      height: dimension,
      width: dimension,
    );
  }

  /// Return an [Image] shows [asset].
  static Image image(
    PackagedAsset asset, {
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    return Image.asset(
      asset.path,
      package: asset.package,
      width: width,
      height: height,
      fit: fit,
      color: color,
    );
  }

  /// Returns complate path of the asset including packages/[package_name]
  static String assetPath(PackagedAsset packagedAsset) {
    return 'packages/${packagedAsset.package}/${packagedAsset.path}';
  }

  /// Return an [AssetImage] loading [asset].
  static AssetImage assetImage(PackagedAsset asset) =>
      AssetImage(asset.path, package: asset.package);
}
