package;

import h3d.scene.Object;
import h3d.Matrix;
import h3d.Vector;
import h3d.mat.BlendMode;
import h3d.scene.Scene;
import h3d.scene.Mesh;
import h3d.col.Bounds;

class Enemy extends Mesh {
    public var bounds: Bounds;

    public function new(s3d: Scene) {
        var prim = new h3d.prim.Cube(40, 0, 50);
        prim.unindex();
        prim.addNormals();
        prim.addUVs();

        var tex = hxd.Res.load("monster_sprite.png").toImage().toTexture();
        var mat = h3d.mat.Material.create(tex);
        mat.blendMode = BlendMode.Alpha;

        super(prim, mat, s3d);

        this.material.receiveShadows = false;

        this.scale(1 / 20);
    }

    public function followPlayer(player: Object, dt: Float) {
        // Calculate direction to player
        var direction = new Vector(Main.player.x - this.x, Main.player.y - this.y, Main.player.z - this.z);
        direction.normalize();

        // Move enemy towards player
        var speed = 50; // Adjust speed as necessary
        this.x += direction.x * speed * dt;
        this.y += direction.y * speed * dt;
    }
}