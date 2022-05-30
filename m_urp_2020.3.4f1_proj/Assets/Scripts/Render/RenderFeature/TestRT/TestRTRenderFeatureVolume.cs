using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace Jefford
{
    // public class TestRTRenderFeatureValue : IEquatable<TestRTRenderFeatureValue>
    // {

    // }

    [VolumeComponentMenu("Jefford/TestRTRenderFeature")]
    public class TestRTRenderFeatureVolume : VolumeComponent, IPostProcessComponent
    {
        public bool IsActive()
        {
            return false;
        }
        public bool IsTileCompatible()
        {
            return false;
        }
    }
}

