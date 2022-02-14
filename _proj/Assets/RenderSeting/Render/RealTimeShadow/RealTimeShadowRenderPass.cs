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
        UniversalRenderPipelineAsset rpAsset;
        public RealTimeShadowRenderPass(RealTimeShadowRenderFeature.RealShadowSettings settings, UniversalRenderPipelineAsset asset)
        {
            this.settings = settings;
            this.rpAsset = asset;
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var stack = VolumeManager.instance.stack;
            var shadowVolume = stack.GetComponent<RealTimeShadowVolume>();
            if (shadowVolume == null || !shadowVolume.active || !shadowVolume.enable.value)
            {
                return;
            }

            rpAsset.shadowDistance = shadowVolume.shadowDistance.value;
            // Debug.LogError(shadowVolume.shadowDistance.value);
        }
    }
}

