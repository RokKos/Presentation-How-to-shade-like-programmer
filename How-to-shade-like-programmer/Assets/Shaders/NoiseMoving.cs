using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class NoiseMoving : MonoBehaviour
{
    [SerializeField] Material mat;
    [SerializeField] int width_ = 346;
    [SerializeField] int heigh_ = 864;

    [SerializeField] float scale_ = 20.0f;
    [SerializeField] float offset_x_ = 20.0f;
    [SerializeField] float offset_y_ = 20.0f;
    [SerializeField] bool move_noise_up = false;
    [SerializeField] float speed = 10;
    float moved_y = 0;

    private void Update()
    {
        
        if (move_noise_up) { moved_y -= Time.deltaTime * speed; }
        mat.SetTexture("_NoiseTex", GenerateNoise(moved_y));

    }

    private Texture2D GenerateNoise(float move_noise_up = 0)
    {
        Texture2D tex = new Texture2D(width_, heigh_);

        for (int x = 0; x < width_; ++x)
        {
            for (int y = 0; y < heigh_; ++y)
            {
                float s_x = (float)x / width_ * scale_ + offset_x_;
                float s_y = (float)y / heigh_ * scale_ + offset_y_ + move_noise_up;
                float p = Mathf.PerlinNoise(s_x, s_y);
                Color c = new Color(p, p, p);
                tex.SetPixel(x, y, c);
            }
        }
        tex.Apply();
        return tex;

    }
}
