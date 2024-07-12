package;

import h3d.mat.Material;
import Project.BodyData;
import h3d.prim.Cube;
import Project.LayerData;
import Project.SceneData;
import hxd.Res;
import h3d.scene.Mesh;
import sdl.Sdl; // Import SDL library
import hxd.Window; // Import Window module from HXD
import hxd.System; // Import System module from HXD
import hxd.Event; // Import Event module from HXD
import h3d.Vector; // Import Vector class from H3D
import h2d.Text; // Import Text class from H2D
import hxd.Key; // Import Key module from HXD

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

// Main class extending HXD's App classdir
class Main extends hxd.App {
    var light: h3d.scene.fwd.DirLight; // Directional light object
    public static var player: Player; // Player object
    var floor: h3d.scene.Object; // Floor object
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
    var damageCooldown: Float = 1.0; // Cooldown in seconds
    var timeSinceLastDamage: Float = 0.0;

    override function init() {
        engine.backgroundColor = 0xFF565656;
        
        var project = new Project();
        var testLevel: SceneData = project.load("levels/TestLevel.json");
        var layer: LayerData = project.defaultLayer();

        cameraMode = FirstPerson; // Initialize camera mode to FirstPerson

        var prim = new h3d.prim.Cube(1000, 1000, 0, true);
        prim.unindex();
        prim.addNormals();
        prim.addUVs();
        var floor = new Mesh(prim, s3d);
        floor.material.color.setColor(0xFF834800);
        floor.material.receiveShadows = false;
        floor.x = 500;
        floor.y = 100;
        floor.z = -19;
        
        var playerData: BodyData = project.getEntity("player");
        player = new Player(s3d, s2d);
        player.x = playerData.x;
        player.y = playerData.y;
        s3d.addChild(player);

        for (item in layer.tiles) {
            if (item.type == 0) {
                var wallPrim = new Cube();
                wallPrim.translate(-0.5, -0.5, -0.5);
                wallPrim.unindex();
                wallPrim.addNormals();
                wallPrim.addUVs();
                var tex = Res.load("WOODB.png").toImage().toTexture();
                var mat = Material.create(tex);
                var wall = new Mesh(wallPrim, mat, s3d);
                wall.material.receiveShadows = false;
                wall.scaleX = item.width;
                wall.scaleY = item.height;
                wall.scaleZ = 40;
                wall.x = item.x;
                wall.y = item.y;
            }

            if (item.name == "enemy") {
                var enemy = new Enemy(s3d);
                enemy.x = item.x;
                enemy.y = item.y;
                enemy.z = -25;
                enemy.scale(20);
                s3d.addChild(enemy);
                enemies.push(enemy);
            }
        }

        cameraHeight = 5; // Set initial camera height
        updateCamera(); // Update camera position and orientation

        // Initialize mouse position and set cursor position
        lastMouseX = s2d.mouseX;
        lastMouseY = s2d.mouseY;
        Window.getInstance().setCursorPos(s2d.width >> 1, s2d.height >> 1);
    }

    override function update(dt: Float) {
        timeSinceLastDamage += dt;

        var currentMouseX = s2d.mouseX;

        // Calculate mouse movement delta
        var deltaX = (currentMouseX - (s2d.width >> 1)) * mouseSensitivity;

        // Update camera orientation based on camera mode
        if (cameraMode == FirstPerson) {
            yaw += deltaX;
            pitch = Math.max(-Math.PI / 2, Math.min(Math.PI / 2, pitch));
        }

        lastMouseX = s2d.width >> 1;
        lastMouseY = s2d.height >> 1;

        for (enemy in enemies) {
            enemy.followPlayer(player, dt);

            if (enemy.getBounds().collide(player.getBounds())) {
                if (timeSinceLastDamage >= damageCooldown) {
                    Res.hurt.play(false, 2);
                    player.health -= 10;
                    timeSinceLastDamage = 0.0;
                }
            }

            for (b in player.bullets) {
                if (b.bullet.getBounds().collide(enemy.getBounds())) {
                    Res.monster_die.play();
                    s3d.removeChild(enemy);
                    enemies.remove(enemy);
                    s3d.removeChild(b.bullet);
                    player.bullets.remove(b);
                }
            }
        }

        // Update player and camera orientation
        player.update(dt);
        updateCamera();

        // Reset mouse position and set relative mouse mode
        Window.getInstance().setCursorPos(s2d.width >> 1, s2d.height >> 1);
        Sdl.setRelativeMouseMode(true);

        // Exit application if ESCAPE key is pressed
        if (Key.isPressed(Key.ESCAPE)) {
            System.exit();
        }
    }

    // Function to update camera position and orientation based on camera mode
    function updateCamera() {
        if (cameraMode == FirstPerson) {
            cameraHeight = 1.5;
            var forwardX = Math.cos(yaw) * Math.cos(pitch);
            var forwardY = Math.sin(yaw) * Math.cos(pitch);
            var forwardZ = Math.sin(pitch);
            s3d.camera.pos.set(player.x, player.y, cameraHeight);
            s3d.camera.target.set(player.x + forwardX, player.y + forwardY, cameraHeight + forwardZ);
        }
    }

    // Main entry point of the application
    static function main() {
        hxd.Res.initEmbed(); // Initialize embedded resources
        new Main(); // Create an instance of Main
    }
}
