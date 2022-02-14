
using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace App.Render
{
    // volume路径
    [Serializable, VolumeComponentMenu("Jefford/RealTime Shadow")]
    public class RealTimeShadowVolume : VolumeComponent, IPostProcessComponent
    {
        // 暴露出来的参数
        public FloatParameter shadowDistance = new FloatParameter(70);
        public BoolParameter enable = new BoolParameter(false);
        public bool IsActive()
        {
            return enable.value;
        }
        public bool IsTileCompatible()
        {
            return false;
        }
    }
}

