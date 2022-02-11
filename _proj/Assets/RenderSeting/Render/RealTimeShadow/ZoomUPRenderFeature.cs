using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class ZoomUPRenderFeature : ScriptableRendererFeature
{
    ZoomUPRenderPass renderPass;

    [System.Serializable]
    public class ShadowSettings
    {
        public string passTag = "ShadowSettingRender";
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRendering;
        public int blitMaterialPassIndex = -1;
        public float shadowHeight = 0.025f;
        public Color shadowColor = new Color(0.012f, 0.012f, 0.02f, 0.8f);
    }
    ShadowSettings settings = new ShadowSettings();

    /// <summary>
    /// 进行初始化，RenderFeature在Create()最先开始执行
    /// </summary>
    public override void Create()
    {
        renderPass = new ZoomUPRenderPass(settings);
        //  一定要设置 RenderFeature的渲染时机
        renderPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(renderPass);
    }
}
