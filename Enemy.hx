package;

import h3d.mat.BlendMode;
import h3d.scene.Scene;
import h3d.scene.Mesh;
import h3d.col.Bounds;

class Enemy extends Mesh {
    public function new(s3d: Scene) {
        var prim = new h3d.prim.Cube(40, 0, 50);
        prim.unindex();
        prim.addNormals();
        prim.addUVs();

        // var tex = hxd.Res.load("monster_sprites.png").toImage().toTexture();
        var tex = hxd.Res.load("monster_sprite.png").toImage().toTexture();
        //var animTex = new AnimatedTexture(tex, 142, 57, 9, 5);
        var mat = h3d.mat.Material.create(tex);
        // mat.mainPass.addShader(animTex);
        mat.blendMode = BlendMode.Alpha;

        super(prim, mat, s3d);

        this.scale(1 / 20);
    }
}