import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The kinds of failures the UI knows how to explain to a visitor.
///
/// Keeping this as a small closed set (rather than passing raw
/// exceptions to widgets) means every screen can show a consistent,
/// friendly message regardless of which Firebase SDK threw what.
enum AppFailureType {
  noInternet,
  permissionDenied,
  notFound,
  invalidCredentials,
  sameLocation,
  noRouteFound,
  emptyGraph,
  unknown,
}

/// A user-facing failure with a friendly title/message, plus the
/// original error kept around for logging/debugging.
class AppFailure {
  const AppFailure({
    required this.type,
    required this.title,
    required this.message,
    this.cause,
  });

  final AppFailureType type;
  final String title;
  final String message;
  final Object? cause;

  /// The visitor picked the same location as both start and destination.
  factory AppFailure.sameLocation() => const AppFailure(
        type: AppFailureType.sameLocation,
        title: "You're already there",
        message: 'Your current location and destination are the same.',
      );

  /// One of the two selected locations doesn't exist in the routing
  /// graph (e.g. it was deleted, or belongs to inactive/stale data).
  factory AppFailure.locationNotFound() => const AppFailure(
        type: AppFailureType.notFound,
        title: 'Location not found',
        message: "We couldn't find one of the selected locations. Please choose again.",
      );

  /// The graph has no walkable path between the two locations — they
  /// exist, but no chain of connections links them.
  factory AppFailure.noRouteFound() => const AppFailure(
        type: AppFailureType.noRouteFound,
        title: 'No route available',
        message: "We couldn't find a walking path between these two locations yet.",
      );

  /// Locations/connections haven't been added to Firestore yet, so
  /// there's no graph to route through at all.
  factory AppFailure.emptyGraph() => const AppFailure(
        type: AppFailureType.emptyGraph,
        title: 'Map data not available',
        message: 'Hospital location data hasn\u2019t been added yet. Please check back soon.',
      );

  /// Maps any exception thrown by Firestore/Auth/Dart's IO layer into a
  /// friendly [AppFailure]. Repositories and services funnel their
  /// try/catch blocks through this so screens never need to know about
  /// `FirebaseException` codes directly.
  factory AppFailure.from(Object error) {
    // Already-mapped failures pass straight through (e.g. rethrown from
    // a repository that already translated the original exception).
    if (error is AppFailure) return error;

    // No internet / DNS failure.
    if (error is SocketException || error is TimeoutException) {
      return AppFailure(
        type: AppFailureType.noInternet,
        title: 'No internet connection',
        message: 'Please check your connection and try again.',
        cause: error,
      );
    }

    if (error is FirebaseAuthException) {
      return _fromAuthException(error);
    }

    if (error is FirebaseException) {
      return _fromFirestoreException(error);
    }

    return AppFailure(
      type: AppFailureType.unknown,
      title: "Something didn't load",
      message: 'Please try again in a moment.',
      cause: error,
    );
  }

  static AppFailure _fromFirestoreException(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return AppFailure(
          type: AppFailureType.permissionDenied,
          title: "You don't have access",
          message: 'This action is restricted to hospital admins.',
          cause: error,
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return AppFailure(
          type: AppFailureType.noInternet,
          title: 'No internet connection',
          message: 'Please check your connection and try again.',
          cause: error,
        );
      case 'not-found':
        return AppFailure(
          type: AppFailureType.notFound,
          title: 'Not found',
          message: "The information you're looking for isn't available.",
          cause: error,
        );
      default:
        return AppFailure(
          type: AppFailureType.unknown,
          title: "Something didn't load",
          message: 'Please try again in a moment.',
          cause: error,
        );
    }
  }

  static AppFailure _fromAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return AppFailure(
          type: AppFailureType.invalidCredentials,
          title: 'Login failed',
          message: 'The email or password you entered is incorrect.',
          cause: error,
        );
      case 'user-disabled':
        return AppFailure(
          type: AppFailureType.permissionDenied,
          title: 'Account disabled',
          message: 'This admin account has been disabled.',
          cause: error,
        );
      case 'too-many-requests':
        return AppFailure(
          type: AppFailureType.unknown,
          title: 'Too many attempts',
          message: 'Please wait a moment before trying again.',
          cause: error,
        );
      case 'network-request-failed':
        return AppFailure(
          type: AppFailureType.noInternet,
          title: 'No internet connection',
          message: 'Please check your connection and try again.',
          cause: error,
        );
      default:
        return AppFailure(
          type: AppFailureType.unknown,
          title: 'Login failed',
          message: 'Please try again in a moment.',
          cause: error,
        );
    }
  }
}
