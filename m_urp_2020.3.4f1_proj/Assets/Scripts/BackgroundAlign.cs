using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace App.Battle
{
    [ExecuteAlways]
    public class BackgroundAlign : MonoBehaviour
    {
        [Header("需要对齐的远裁剪面Quad")]
        public GameObject farquad;

        [Header("需要对齐的近裁剪面Quad")]
        public GameObject nearquard;

        public bool isEnableUI = false;


        [Header("图片实际大小 ")]
        public Vector2 bgsize = new Vector2(1920, 1080);

        public float scale = 1;

        public void Align(GameObject quad, Camera cam, float camPlane)
        {

            if (cam == null)
            {
                Debug.LogError("缺少主摄像机");
                return;
            }

            if (quad == null)
            {
                return;
            }

            var design = new Vector2(Screen.width, Screen.height);
            if (Mathf.Abs(design.y - 1080f) > 0.1f || (design.x < 1920 || design.x > 2400))
            {
                Debug.LogError("Game视图的分辨 应该设置为 x * 1080, x范围(1920, 2400), 如2200*1080");
                return;
            }

            //位置
            quad.transform.position = cam.transform.position + cam.transform.forward * camPlane;
            //旋转
            quad.transform.rotation = cam.transform.rotation;
            //大小
            var fov = cam.fieldOfView * UnityEngine.Mathf.Deg2Rad;

            var heightInWorld = UnityEngine.Mathf.Tan(fov * 0.5f) * camPlane * 2;
            var widthInWorld = heightInWorld * cam.aspect;

            var realHeightInWorld = heightInWorld * bgsize.y / design.y;
            var realWidthInWorld = widthInWorld * bgsize.x / design.x;
            quad.transform.localScale = new Vector3(realWidthInWorld * scale, realHeightInWorld * scale, 1f);
        }

        private void Update()
        {
            var cam = Camera.main;
            this.Align(farquad, cam, cam.farClipPlane);
            if (isEnableUI)
            {
                this.Align(nearquard, cam, cam.nearClipPlane);
            }
        }



    }
}
