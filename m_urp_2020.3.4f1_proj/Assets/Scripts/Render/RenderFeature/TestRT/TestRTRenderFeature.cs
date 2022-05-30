using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Jefford
{
    public class TestRTRenderFeature : ScriptableRendererFeature
    {

        TestRTRenderPass renderPass;
        public TestRT testRTSetting = new TestRT();

        [System.Serializable]
        public class TestRT
        {
            public RenderPassEvent m_event = RenderPassEvent.AfterRenderingOpaques;
            [Range(1, 6)]
            public int m_DownSample = 1;
            public Material m_DrawMeshMaterial;
        }

        public override void Create()
        {
            renderPass = new TestRTRenderPass();
            renderPass.renderPassEvent = testRTSetting.m_event;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderPass.Setup(renderer.cameraColorTarget, testRTSetting, renderer);
            renderer.EnqueuePass(renderPass);
        }
    }
}

