package;

import hxd.Res;
import h2d.Anim;
import h3d.Vector;
import h3d.scene.Graphics;
import hxd.Key;
import h3d.scene.Object;
import h3d.scene.Scene;
import h3d.prim.Capsule;
import h3d.scene.Mesh;

class Player extends Object {
    var isMoving: Bool = false; // Flag indicating if player is moving
    var playerSpeed: Float; // Player's speed factor
    var walkSpeed: Float = 0.04; // Base walking speed
    var movementSpeed: Float = 0.0; // Current movement speed of player
    var s3d: Scene;
    var s2d: h2d.Scene;
    var gun: Anim;
    var gunFrames = Res.gun_sprites.toTile().split(4);
    
    public var bullets: Array<{bullet: Mesh, direction: Vector}> = [];

    public function new(s3d: Scene, s2d: h2d.Scene) {
        this.s3d = s3d;
        this.s2d = s2d;
        super(this.s3d);

        this.scale(1 / 20);

        var graphics = new h2d.Graphics(s2d);
        graphics.beginFill(0xFFFFA200);
        graphics.drawRect(s2d.width / 2, s2d.height / 2, 5, 5);
        graphics.endFill();

        gun = new Anim(gunFrames, 0, s2d);
        gun.setPosition(s2d.width / 2, s2d.height / 3);
    }

    public function update(dt: Float) {
        // Determine player speed based on key input
        var forwardSpeed = 0.0;
        var sidewaysSpeed = 0.0;
    
        if (hxd.Key.isDown(hxd.Key.W)) {
            forwardSpeed += 3;
        }
        if (hxd.Key.isDown(hxd.Key.S)) {
            forwardSpeed -= 3;
        }
        if (hxd.Key.isDown(hxd.Key.A)) {
            sidewaysSpeed -= 1;
        }
        if (hxd.Key.isDown(hxd.Key.D)) {
            sidewaysSpeed += 1;
        }
    
        // Adjust movement speed for running
        var runningMultiplicator = 1.0;
        if (hxd.Key.isDown(hxd.Key.SHIFT)) {
            runningMultiplicator = forwardSpeed != 0 ? 2.0 : 1.3;
        }
    
        // Calculate movement vectors based on current yaw (facing direction)
        var forwardX = Math.cos(Main.yaw) * forwardSpeed * walkSpeed;
        var forwardY = Math.sin(Main.yaw) * forwardSpeed * walkSpeed;
        var sidewaysX = -Math.sin(Main.yaw) * sidewaysSpeed * walkSpeed;
        var sidewaysY = Math.cos(Main.yaw) * sidewaysSpeed * walkSpeed;
    
        // Move player based on current speed and direction
        if (forwardSpeed != 0 || sidewaysSpeed != 0) {
            Main.playerPosition.x += forwardX + sidewaysX;
            Main.playerPosition.y += forwardY + sidewaysY;
    
            isMoving = true;
        } else {
            isMoving = false;
        }
    
        playerShoot();
        moveBullets(dt);
    }

    function moveBullets(dt: Float) {
        for (b in bullets) {
            b.bullet.x += b.direction.x * 600 * dt;
            b.bullet.y += b.direction.y * 600 * dt;
        }
    }

    function playerShoot() {
        if (Key.isPressed(Key.MOUSE_LEFT)) {
            Res.revolver_shot1.play();
            gun.play([gunFrames[1], gunFrames[2], gunFrames[3], gunFrames[0]]);
            gun.speed = 15;
            gun.loop = false;

            var prim = new h3d.prim.Cube(0.01, 0.01, 0.01, true);
            prim.unindex();
            prim.addNormals();
            prim.addUVs();
            var bullet = new Mesh(prim, this.s3d);
            // Set the bullet position to the player's position
            bullet.setPosition(Main.playerPosition.x, Main.playerPosition.y, this.z + 0.5);

            // Calculate the direction vector based on player's facing direction (Main.yaw)
            var direction = new Vector(Math.cos(Main.yaw), Math.sin(Main.yaw), 0);

            // Normalize direction vector to ensure consistent bullet speed
            var length = Math.sqrt(direction.x * direction.x + direction.y * direction.y);
            direction.x /= length;
            direction.y /= length;

            bullet.material.color.setColor(0x00FFFFFF);

            bullets.push({bullet: bullet, direction: direction});
        }
    }
}
