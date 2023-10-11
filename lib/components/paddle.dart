// Copyright (c) 2022 Razeware LLC

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical
// or instructional purposes related to programming, coding, application
// development, or information technology.  Permission for such use, copying,
// modification, merger, publication, distribution, sublicensing, creation of
// derivative works, or sale is expressly withheld.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/rendering.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../forge2d_game_world.dart';

class Paddle extends BodyComponent<Forge2dGameWorld>
    with DragCallbacks, HasGameRef<Forge2dGameWorld> {
  final Size size;
  final BodyComponent ground;
  @override
  final Vector2 position;

  Paddle({
    required this.size,
    required this.ground,
    required this.position,
  });

  MouseJoint? _mouseJoint;
  Vector2 dragStartPosition = Vector2.zero();
  Vector2 dragAccumlativePosition = Vector2.zero();

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position
      ..fixedRotation = true
      ..angularDamping = 1.0
      ..linearDamping = 10.0;

    final paddleBody = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(
        size.width / 2.0,
        size.height / 2.0,
        Vector2(0.0, 0.0),
        0.0,
      );

    paddleBody.createFixture(FixtureDef(shape)
      ..density = 100.0
      ..friction = 0.0
      ..restitution = 1.0);

    return paddleBody;
  }

  void reset() {
    body.setTransform(position, angle);
    body.angularVelocity = 0.0;
    body.linearVelocity = Vector2.zero();
  }

  @override
  void onMount() {
    super.onMount();

    final worldAxis = Vector2(1.0, 0.0);

    final travelExtent = (gameRef.size.x / 2) - (size.width / 2.0);

    final jointDef = PrismaticJointDef()
      ..enableLimit = true
      ..lowerTranslation = -travelExtent
      ..upperTranslation = travelExtent
      ..collideConnected = true;

    jointDef.initialize(body, ground.body, body.worldCenter, worldAxis);
    final joint = PrismaticJoint(jointDef);
    world.createJoint(joint);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_mouseJoint != null) {
      return;
    }
    dragStartPosition = event.devicePosition;
    // event.eventPosition.game;
    _setupDragControls();

    // Don't continue passing the event.
    return;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    dragAccumlativePosition += event.delta;
    if ((dragAccumlativePosition - dragStartPosition).length > 0.1) {
      _mouseJoint?.setTarget(dragAccumlativePosition);
      dragStartPosition = dragAccumlativePosition;
    }

    // Don't continue passing the event.
    return false;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _resetDragControls();

    // Don't continue passing the event.
    return false;
  }

  @override
  bool onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _resetDragControls();

    // Don't continue passing the event.
    return false;
  }

  void _setupDragControls() {
    final mouseJointDef = MouseJointDef()
      ..bodyA = ground.body
      ..bodyB = body
      ..frequencyHz = 5.0
      ..dampingRatio = 0.9
      ..collideConnected = false
      ..maxForce = 2000.0 * body.mass;

    _mouseJoint = MouseJoint(mouseJointDef);
    world.createJoint(_mouseJoint!);
  }

  // Clear the drag position accumulator and remove the mouse joint.
  void _resetDragControls() {
    dragAccumlativePosition = Vector2.zero();
    if (_mouseJoint != null) {
      world.destroyJoint(_mouseJoint!);
      _mouseJoint = null;
    }
  }

  @override
  void render(Canvas canvas) {
    final shape = body.fixtures.first.shape as PolygonShape;

    final paint = Paint()
      ..color = const Color.fromARGB(255, 80, 80, 228)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromLTRB(
          shape.vertices[0].x,
          shape.vertices[0].y,
          shape.vertices[2].x,
          shape.vertices[2].y,
        ),
        paint);
  }
}
