using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace App.Render
{
    public class RealTimeShadowRenderPass : ScriptableRenderPass
    {
        RealTimeShadowRenderFeature.RealShadowSettings settings;
        public RealTimeShadowRenderPass(RealTimeShadowRenderFeature.RealShadowSettings settings)
        {
            this.settings = settings;
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var stack = VolumeManager.instance.stack;
            var shadowVolume = stack.GetComponent<RealTimeShadowVolume>();
            if (shadowVolume == null || !shadowVolume.active || !shadowVolume.enable.value)
            {
                return;
            }
            SetShadowParams();
            Debug.LogError(renderingData.cameraData.maxShadowDistance);
        }

        private void SetShadowParams()
        {

        }

    }
}

