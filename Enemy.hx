package;

import h3d.scene.AnimMeshBatcher;
import h3d.scene.AnimMeshBatcher.AnimMeshBatch;
import h3d.shader.AnimatedTexture;
import h3d.anim.Animation;
import h3d.scene.Scene;
import h3d.scene.Mesh;
import h3d.col.Bounds;

class Enemy extends Mesh {
    public var hitbox: Bounds;

    public function new(s3d: Scene) {
        var prim = new h3d.prim.Cube(30, 0, 40);
        prim.unindex();
        prim.addNormals();
        prim.addUVs();

        var tex = hxd.Res.load("monster_sprites.png").toImage().toTexture();
        var mat = h3d.mat.Material.create(tex);
        mat.blendMode = Alpha;

        super(prim, mat, s3d);

        this.scale(1 / 20);

        hitbox = Bounds.fromValues(1, 1, 1, 1, 1, 1);
    }
}