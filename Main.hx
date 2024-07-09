package;

import h3d.col.Bounds;
import h3d.scene.Object;
import h3d.col.Ray;
import h2d.Graphics;
import h2d.Bitmap;
import h3d.scene.Mesh;
import h3d.prim.Capsule;
import h3d.col.Point;
import h3d.Engine;
import sdl.Sdl; // Import SDL library
import hxd.Window; // Import Window module from HaxeD
import hxd.System; // Import System module from HaxeD
import hxd.Event; // Import Event module from HaxeD
import h3d.Vector; // Import Vector class from H3D
import h2d.Text; // Import Text class from H2D
import hxd.Key; // Import Key module from HaxeD

// Define a Rect class for a rectangle's position and dimensions
class Rect {
    public var x: Float;
    public var y: Float;
    public var width: Float;
    public var height: Float;

    public function new(x: Float = 0, y: Float = 0, width: Float = 0, height: Float = 0) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }
}

// Define an enum for different camera modes
enum CameraMode {
    FirstPerson; // First-person camera mode
}

// Main class extending HaxeD's App classdir
class Main extends hxd.App {
    var light: h3d.scene.fwd.DirLight; // Directional light object
    var player: Player; // Player object
    var floor: h3d.scene.Object; // Floor object
    public static var playerPosition: Point; // Player's current position
    var cameraDistance: Float; // Camera distance from player
    public static var cameraHeight: Float; // Camera height from player
    var cache: h3d.prim.ModelCache; // Model cache for storing loaded models
    var walkingAnimation: h3d.anim.Animation; // Walking animation object
    var cylinder: h3d.scene.Mesh; // Cylinder mesh for player
    var circle: differ.shapes.Circle; // Circle shape for player collision
    var obstacles: Array<differ.shapes.Polygon>; // Array of obstacles in the scene
    var cameraMode: CameraMode; // Current camera mode (FirstPerson or ThirdPerson)
    var cameraModeText: Text; // Text object for displaying camera mode
    var lastMouseX: Float = 0.0; // Last recorded mouse X position
    var lastMouseY: Float = 0.0; // Last recorded mouse Y position
    var mouseSensitivity: Float = 0.002; // Mouse sensitivity for camera control
    public static var yaw: Float = 0.0; // Yaw angle for camera orientation
    public static var pitch: Float = 0.0; // Pitch angle for camera orientation
    var enemies: Array<Enemy> = [];

    override function init() {
        engine.backgroundColor = 0xFF63E0FF;

        cameraMode = FirstPerson; // Initialize camera mode to FirstPerson
        
        player = new Player(s3d, s2d);
        s3d.addChild(player);
        playerPosition = new Point(player.x, player.y);

        for (i in 0...1) {
            var enemy = new Enemy(s3d);
            enemy.setPosition(20 / 3, 20 / 3, 0);
            s3d.addChild(enemy);
        }

        // Create floor mesh and set its properties
        var prim = new h3d.prim.Cube(20, 20, 0);
        prim.unindex();
        prim.addNormals();
        prim.addUVs();
        var floor = new h3d.scene.Mesh(prim, s3d);
        floor.material.color.setColor(0x552709);
        floor.x = -10;
        floor.y = -10;
        floor.z = -0.08;

        circle = new differ.shapes.Circle(0, 0, 0.35);

        // Perform initial collision check
        //collideWithObstacles();

        cameraHeight = 5; // Set initial camera height
        updateCamera(); // Update camera position and orientation

        // Initialize mouse position and set cursor position
        lastMouseX = s2d.mouseX;
        lastMouseY = s2d.mouseY;
        Window.getInstance().setCursorPos(s2d.width >> 1, s2d.height >> 1);
    }

    override function update(dt: Float) {
        var currentMouseX = s2d.mouseX;
        var currentMouseY = s2d.mouseY;

        // Calculate mouse movement delta
        var deltaX = (currentMouseX - (s2d.width >> 1)) * mouseSensitivity;
        var deltaY = (currentMouseY - (s2d.height >> 1)) * mouseSensitivity;

        // Update camera orientation based on camera mode
        if (cameraMode == FirstPerson) {
            yaw += deltaX;
            pitch = Math.max(-Math.PI / 2, Math.min(Math.PI / 2, pitch));
        }

        lastMouseX = s2d.width >> 1;
        lastMouseY = s2d.height >> 1;

        // Update player and camera orientation
        player.update(dt);
        updateCamera();

        // Reset mouse position and set relative mouse mode
        Window.getInstance().setCursorPos(s2d.width >> 1, s2d.height >> 1);
        Sdl.setRelativeMouseMode(true);

        // Switch camera mode based on key input
        if (Key.isPressed(Key.NUMBER_1)) {
            cameraMode = FirstPerson;
        }

        // Exit application if ESCAPE key is pressed
        if (Key.isPressed(Key.ESCAPE)) {
            System.exit();
        }
    }

    // Function to handle collision detection with obstacles
    // function collideWithWalls() {
    //     circle.x = playerPosition.x;
    //     circle.y = playerPosition.y;

    //     for (i in 0...obstacles.length) {
    //         var obstacle = obstacles[i];
    //         var collideInfo = differ.Collision.shapeWithShape(circle, obstacle);
    //         if (collideInfo != null) {
    //             circle.x += collideInfo.separationX;
    //             circle.y += collideInfo.separationY;
    //         }
    //     }

    //     playerPosition.x = circle.x;
    //     playerPosition.y = circle.y;
    //     player.x = playerPosition.x;
    //     player.y = playerPosition.y;
    //     cylinder.x = playerPosition.x;
    //     cylinder.y = playerPosition.y;
    // }

    // Function to update camera position and orientation based on camera mode
    function updateCamera() {
        if (cameraMode == FirstPerson) {
            cameraHeight = 1.5;
            var forwardX = Math.cos(yaw) * Math.cos(pitch);
            var forwardY = Math.sin(yaw) * Math.cos(pitch);
            var forwardZ = Math.sin(pitch);
            s3d.camera.pos.set(playerPosition.x, playerPosition.y, cameraHeight);
            s3d.camera.target.set(playerPosition.x + forwardX, playerPosition.y + forwardY, cameraHeight + forwardZ);
        }
    }

    // Main entry point of the application
    static function main() {
        hxd.Res.initEmbed(); // Initialize embedded resources
        new Main(); // Create an instance of Main
    }
}
