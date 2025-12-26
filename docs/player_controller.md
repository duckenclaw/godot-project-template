# PlayerController

The player script is the main controller for the player. It handles all of the inputs and utilizes the StateMachine to transition between states. The states themselves contain all of the logic for the movement. The Hands are used to handle attacks using left and right hands through Hand class. And finally the Camera script is used to handle the camera movement.

Actions:

- forward
- backward
- left
- right
- tilt_left
- tilt_right
- jump
- dash
- interact
- left_hand
- right_hand
- crouch
- sprint

states:

- idle: standing
- moving: regular movement, sprint handling (only when moving forward), crouch movement
- jumping: jump height varies when holding jump, add coyote time.
- dashing: moves the player in the direction of the camera (vertically as well) for a short time
- sliding: only transitions to this state when the player is moving and presses crouch. moves him in the direction he is facing horizontally until crouch is released or his speed decreases to zero. momentum carries from the moving state
- wallruning: transitions to this state when the player is in the air and moves along the wall, don't transition when player is facing the wall. when in this state the player moves along the wall and slightly down, when he presses jump he jumps from the wall and slightly upward
- falling

hierarchy:

- Player (Player)
  - CollisionShape3D
  - CameraPivot (Camera)
    - Camera3D
      - InteractRayCast: used for "interact" action, first checks if the colliding node has interact() method, then uses it if it's present.
    - Hands
      - RightHand (Hand)
      - LeftHand (Hand)
  - StateMachine
    - IdleState
    - MovingState
    - JumpingState
    - FallingState

Player:
handles all input and communication with Camera, Hands and StateMachine.

PlayerConfig:
stores all of the player settings such as movement speed, jump force, camera sensitivity etc.

Camera:
Camera movement and rotation as well as tilting (through "tilt_left" and "tilt_right" actions). Head bobbing on walk, screen shake, fov controls (increase fov when speed is high)

Hand:
handles item equipping and attacking through the currently equipped item.

StateMachine:
handles the state transitions between the states.