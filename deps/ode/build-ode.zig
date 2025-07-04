const std = @import("std");

const ODE_SRC = "deps/ode/src/";

pub const OdeSettings = struct {
    /// Use double-precision math.
    double_precision: bool = false,
    /// Use 16-bit indices for trimeshes (default is 32-bit).
    indices_16_bit: bool = false,
    /// Disable built-in multithreaded threading implementation.
    no_builtin_threading_impl: bool = false,
    /// Disable threading interface support (external implementations cannot be assigned.
    no_threading_intf: bool = false,
    /// Use old OPCODE trimesh-trimesh collider.
    old_trimesh: bool = false,
    /// Use GIMPACT for trimesh collisions (experimental).
    with_gimpact: bool = false,
    /// Use libccd for handling some collision tests absent in ODE.
    with_libccd: LibCCD = .{},
    /// Use old OPCODE trimesh-trimesh collider.
    with_opcode: bool = false,
    /// Use TLS for global caches (allows threaded collision checks for separated spaces).
    with_ou: bool = true,
};

pub const LibCCD = packed struct(u8) {
    BOX_CYL: bool = false,
    CAP_CYL: bool = false,
    CYL_CYL: bool = false,
    CONVEX_BOX: bool = false,
    CONVEX_CAP: bool = false,
    CONVEX_CONVEX: bool = false,
    CONVEX_CYL: bool = false,
    CONVEX_SPHERE: bool = false,
};

pub fn build(
    exe: *std.Build.Step.Compile,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    settings: OdeSettings,
) void {
    exe.root_module.addCMacro("dODE_VERSION", "0.16.6");

    addBaseSourceFiles(exe);
    defineSettingsMacros(exe, settings);
    defineConfigHMacros(exe, target);
    defineOptimizationMacros(exe, optimize);

    exe.linkLibCpp();
}

fn addBaseSourceFiles(exe: *std.Build.Step.Compile) void {
    exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "../ode-headers/" });
    exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "include" });
    exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "ode/src" });
    exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "ode/src/joints" });

    exe.addCSourceFiles(.{ .files = &[_][]const u8{
        ODE_SRC ++ "ode/src/array.cpp",
        ODE_SRC ++ "ode/src/box.cpp",
        ODE_SRC ++ "ode/src/capsule.cpp",
        ODE_SRC ++ "ode/src/collision_cylinder_box.cpp",
        ODE_SRC ++ "ode/src/collision_cylinder_plane.cpp",
        ODE_SRC ++ "ode/src/collision_cylinder_sphere.cpp",
        ODE_SRC ++ "ode/src/collision_kernel.cpp",
        ODE_SRC ++ "ode/src/collision_quadtreespace.cpp",
        ODE_SRC ++ "ode/src/collision_sapspace.cpp",
        ODE_SRC ++ "ode/src/collision_space.cpp",
        ODE_SRC ++ "ode/src/collision_transform.cpp",
        ODE_SRC ++ "ode/src/collision_trimesh_disabled.cpp",
        ODE_SRC ++ "ode/src/collision_util.cpp",
        ODE_SRC ++ "ode/src/convex.cpp",
        ODE_SRC ++ "ode/src/cylinder.cpp",
        ODE_SRC ++ "ode/src/default_threading.cpp",
        ODE_SRC ++ "ode/src/error.cpp",
        ODE_SRC ++ "ode/src/export-dif.cpp",
        ODE_SRC ++ "ode/src/fastdot.cpp",
        ODE_SRC ++ "ode/src/fastldltfactor.cpp",
        ODE_SRC ++ "ode/src/fastldltsolve.cpp",
        ODE_SRC ++ "ode/src/fastlsolve.cpp",
        ODE_SRC ++ "ode/src/fastltsolve.cpp",
        ODE_SRC ++ "ode/src/fastvecscale.cpp",
        ODE_SRC ++ "ode/src/heightfield.cpp",
        ODE_SRC ++ "ode/src/lcp.cpp",
        ODE_SRC ++ "ode/src/mass.cpp",
        ODE_SRC ++ "ode/src/mat.cpp",
        ODE_SRC ++ "ode/src/matrix.cpp",
        ODE_SRC ++ "ode/src/memory.cpp",
        ODE_SRC ++ "ode/src/misc.cpp",
        ODE_SRC ++ "ode/src/nextafterf.c",
        ODE_SRC ++ "ode/src/objects.cpp",
        ODE_SRC ++ "ode/src/obstack.cpp",
        ODE_SRC ++ "ode/src/ode.cpp",
        ODE_SRC ++ "ode/src/odeinit.cpp",
        ODE_SRC ++ "ode/src/odemath.cpp",
        ODE_SRC ++ "ode/src/plane.cpp",
        ODE_SRC ++ "ode/src/quickstep.cpp",
        ODE_SRC ++ "ode/src/ray.cpp",
        ODE_SRC ++ "ode/src/resource_control.cpp",
        ODE_SRC ++ "ode/src/rotation.cpp",
        ODE_SRC ++ "ode/src/simple_cooperative.cpp",
        ODE_SRC ++ "ode/src/sphere.cpp",
        ODE_SRC ++ "ode/src/step.cpp",
        ODE_SRC ++ "ode/src/threading_base.cpp",
        ODE_SRC ++ "ode/src/threading_impl.cpp",
        ODE_SRC ++ "ode/src/threading_pool_posix.cpp",
        ODE_SRC ++ "ode/src/threading_pool_win.cpp",
        ODE_SRC ++ "ode/src/timer.cpp",
        ODE_SRC ++ "ode/src/util.cpp",
        ODE_SRC ++ "ode/src/joints/amotor.cpp",
        ODE_SRC ++ "ode/src/joints/ball.cpp",
        ODE_SRC ++ "ode/src/joints/contact.cpp",
        ODE_SRC ++ "ode/src/joints/dball.cpp",
        ODE_SRC ++ "ode/src/joints/dhinge.cpp",
        ODE_SRC ++ "ode/src/joints/fixed.cpp",
        ODE_SRC ++ "ode/src/joints/hinge.cpp",
        ODE_SRC ++ "ode/src/joints/hinge2.cpp",
        ODE_SRC ++ "ode/src/joints/joint.cpp",
        ODE_SRC ++ "ode/src/joints/lmotor.cpp",
        ODE_SRC ++ "ode/src/joints/null.cpp",
        ODE_SRC ++ "ode/src/joints/piston.cpp",
        ODE_SRC ++ "ode/src/joints/plane2d.cpp",
        ODE_SRC ++ "ode/src/joints/pr.cpp",
        ODE_SRC ++ "ode/src/joints/pu.cpp",
        ODE_SRC ++ "ode/src/joints/slider.cpp",
        ODE_SRC ++ "ode/src/joints/transmission.cpp",
        ODE_SRC ++ "ode/src/joints/universal.cpp",
    } });
}

fn defineSettingsMacros(exe: *std.Build.Step.Compile, settings: OdeSettings) void {
    if (settings.double_precision) {
        exe.root_module.addCMacro("dDOUBLE", "1");
        exe.root_module.addCMacro("CCD_DOUBLE", "1");
    } else {
        exe.root_module.addCMacro("dSINGLE", "1");
        exe.root_module.addCMacro("CCD_SINGLE", "1");
    }

    if (settings.indices_16_bit) {
        exe.root_module.addCMacro("dTRIMESH_16BIT_INDICES", "1");
    }

    if (!settings.no_builtin_threading_impl) {
        exe.root_module.addCMacro("dBUILTIN_THREADING_IMPL_ENABLED", "1");
    }

    if (!settings.no_threading_intf) {
        exe.root_module.addCMacro("dTHREADING_INTF_DISABLED", "1");
    }

    if (settings.with_opcode) {
        exe.root_module.addCMacro("dTRIMESH_ENABLED", "1");
        exe.root_module.addCMacro("dTRIMESH_OPCODE", "1");

        if (settings.old_trimesh) {
            exe.root_module.addCMacro("dTRIMESH_OPCODE_USE_OLD_TRIMESH_TRIMESH_COLLIDER", "1");
        }

        exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "OPCODE" });
        exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "OPCODE/Ice" });
        exe.addCSourceFiles(.{ .files = &[_][]const u8{
            ODE_SRC ++ "ode/src/collision_convex_trimesh.cpp",
            ODE_SRC ++ "ode/src/collision_cylinder_trimesh.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_box.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_ccylinder.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_internal.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_opcode.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_plane.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_ray.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_sphere.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_trimesh.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_trimesh_old.cpp",
            ODE_SRC ++ "OPCODE/OPC_AABBCollider.cpp",
            ODE_SRC ++ "OPCODE/OPC_AABBTree.cpp",
            ODE_SRC ++ "OPCODE/OPC_BaseModel.cpp",
            ODE_SRC ++ "OPCODE/OPC_Collider.cpp",
            ODE_SRC ++ "OPCODE/OPC_Common.cpp",
            ODE_SRC ++ "OPCODE/OPC_HybridModel.cpp",
            ODE_SRC ++ "OPCODE/OPC_LSSCollider.cpp",
            ODE_SRC ++ "OPCODE/OPC_MeshInterface.cpp",
            ODE_SRC ++ "OPCODE/OPC_Model.cpp",
            ODE_SRC ++ "OPCODE/OPC_OBBCollider.cpp",
            ODE_SRC ++ "OPCODE/OPC_OptimizedTree.cpp",
            ODE_SRC ++ "OPCODE/OPC_Picking.cpp",
            ODE_SRC ++ "OPCODE/OPC_PlanesCollider.cpp",
            ODE_SRC ++ "OPCODE/OPC_RayCollider.cpp",
            ODE_SRC ++ "OPCODE/OPC_SphereCollider.cpp",
            ODE_SRC ++ "OPCODE/OPC_TreeBuilders.cpp",
            ODE_SRC ++ "OPCODE/OPC_TreeCollider.cpp",
            ODE_SRC ++ "OPCODE/OPC_VolumeCollider.cpp",
            ODE_SRC ++ "OPCODE/Opcode.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceAABB.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceContainer.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceHPoint.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceIndexedTriangle.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceMatrix3x3.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceMatrix4x4.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceOBB.cpp",
            ODE_SRC ++ "OPCODE/Ice/IcePlane.cpp",
            ODE_SRC ++ "OPCODE/Ice/IcePoint.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceRandom.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceRay.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceRevisitedRadix.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceSegment.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceTriangle.cpp",
            ODE_SRC ++ "OPCODE/Ice/IceUtils.cpp",
        } });
    }

    if (settings.with_gimpact) {
        exe.root_module.addCMacro("dTRIMESH_ENABLED", "1");
        exe.root_module.addCMacro("dTRIMESH_GIMPACT", "1");

        exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "GIMPACT/include" });
        exe.addCSourceFiles(.{ .files = &[_][]const u8{
            ODE_SRC ++ "GIMPACT/src/gim_boxpruning.cpp",
            ODE_SRC ++ "GIMPACT/src/gim_contact.cpp",
            ODE_SRC ++ "GIMPACT/src/gim_math.cpp",
            ODE_SRC ++ "GIMPACT/src/gim_memory.cpp",
            ODE_SRC ++ "GIMPACT/src/gim_tri_tri_overlap.cpp",
            ODE_SRC ++ "GIMPACT/src/gim_trimesh.cpp",
            ODE_SRC ++ "GIMPACT/src/gim_trimesh_capsule_collision.cpp",
            ODE_SRC ++ "GIMPACT/src/gim_trimesh_ray_collision.cpp",
            ODE_SRC ++ "GIMPACT/src/gim_trimesh_sphere_collision.cpp",
            ODE_SRC ++ "GIMPACT/src/gim_trimesh_trimesh_collision.cpp",
            ODE_SRC ++ "GIMPACT/src/gimpact.cpp",
            ODE_SRC ++ "ode/src/collision_convex_trimesh.cpp",
            ODE_SRC ++ "ode/src/collision_cylinder_trimesh.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_box.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_ccylinder.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_gimpact.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_internal.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_plane.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_ray.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_sphere.cpp",
            ODE_SRC ++ "ode/src/collision_trimesh_trimesh.cpp",
            ODE_SRC ++ "ode/src/gimpact_contact_export_helper.cpp",
        } });
    }

    if (@as(u8, @bitCast(settings.with_libccd)) > 0) {
        exe.root_module.addCMacro("dLIBCCD_ENABLED", "1");
        exe.root_module.addCMacro("dLIBCCD_INTERNAL", "1");

        exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "libccd/src" });
        exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "libccd/src/custom" });
        exe.addCSourceFiles(.{ .files = &[_][]const u8{
            ODE_SRC ++ "libccd/src/alloc.c",
            ODE_SRC ++ "libccd/src/ccd.c",
            ODE_SRC ++ "libccd/src/mpr.c",
            ODE_SRC ++ "libccd/src/polytope.c",
            ODE_SRC ++ "libccd/src/support.c",
            ODE_SRC ++ "libccd/src/vec3.c",
            ODE_SRC ++ "ode/src/collision_libccd.cpp",
        } });

        if (settings.with_libccd.BOX_CYL) {
            exe.root_module.addCMacro("dLIBCCD_BOX_CYL", "1");
        }

        if (settings.with_libccd.CAP_CYL) {
            exe.root_module.addCMacro("dLIBCCD_CAP_CYL", "1");
        }

        if (settings.with_libccd.CYL_CYL) {
            exe.root_module.addCMacro("dLIBCCD_CYL_CYL", "1");
        }

        if (settings.with_libccd.CONVEX_BOX) {
            exe.root_module.addCMacro("dLIBCCD_CONVEX_BOX", "1");
        }

        if (settings.with_libccd.CONVEX_CAP) {
            exe.root_module.addCMacro("dLIBCCD_CONVEX_CAP", "1");
        }

        if (settings.with_libccd.CONVEX_CONVEX) {
            exe.root_module.addCMacro("dLIBCCD_CONVEX_CONVEX", "1");
        }

        if (settings.with_libccd.CONVEX_CYL) {
            exe.root_module.addCMacro("dLIBCCD_CONVEX_CYL", "1");
        }

        if (settings.with_libccd.CONVEX_SPHERE) {
            exe.root_module.addCMacro("dLIBCCD_CONVEX_SPHERE", "1");
        }
    }

    {
        // ou appears to always be enabled, at least in the CMake build system.
        exe.root_module.addCMacro("dOU_ENABLED", "1");
        exe.root_module.addCMacro("_OU_NAMESPACE", "odeou");

        exe.addIncludePath(.{ .cwd_relative = ODE_SRC ++ "ou/include" });
        exe.addCSourceFiles(.{ .files = &[_][]const u8{
            ODE_SRC ++ "ode/src/odeou.cpp",
            ODE_SRC ++ "ode/src/odetls.cpp",
            ODE_SRC ++ "ou/src/ou/atomic.cpp",
            ODE_SRC ++ "ou/src/ou/customization.cpp",
            ODE_SRC ++ "ou/src/ou/malloc.cpp",
            ODE_SRC ++ "ou/src/ou/threadlocalstorage.cpp",
        } });

        if (settings.with_ou) {
            exe.root_module.addCMacro("_OU_FEATURE_SET", "2"); // #define _OU_FEATURE_SET_TLS 2
            exe.root_module.addCMacro("dATOMICS_ENABLED", "1");
            exe.root_module.addCMacro("dTLS_ENABLED", "1");
        } else if (!settings.no_threading_intf) {
            exe.root_module.addCMacro("_OU_FEATURE_SET", "1"); // #define _OU_FEATURE_SET_ATOMICS 1
            exe.root_module.addCMacro("dTLS_ENABLED", "1");
        } else {
            exe.root_module.addCMacro("_OU_FEATURE_SET", "0"); // #define _OU_FEATURE_SET_BASICS 0
        }
    }
}

fn defineConfigHMacros(exe: *std.Build.Step.Compile, target: std.Build.ResolvedTarget) void {
    if (target.result.os.tag != .windows) {
        exe.root_module.addCMacro("HAVE_ALLOCA_H", "1");
        // exe.root_module.addCMacro("HAVE_PTHREAD_ATTR_SETSTACKLAZY", "1");
    }

    exe.root_module.addCMacro("HAVE_GETTIMEOFDAY", "1");
    exe.root_module.addCMacro("HAVE_INTTYPES_H", "1");
    exe.root_module.addCMacro("HAVE_ISNAN", "1");
    exe.root_module.addCMacro("HAVE_ISNANF", "1");
    exe.root_module.addCMacro("HAVE_PTHREAD_CONDATTR_SETCLOCK", "1");
    exe.root_module.addCMacro("HAVE_STDINT_H", "1");
    exe.root_module.addCMacro("HAVE_SYS_TIME_H", "1");
    exe.root_module.addCMacro("HAVE_SYS_TYPES_H", "1");
    exe.root_module.addCMacro("HAVE_UNISTD_H", "1");
    exe.root_module.addCMacro("HAVE__ISNAN", "1");
    exe.root_module.addCMacro("HAVE__ISNANF", "1");
    exe.root_module.addCMacro("HAVE___ISNAN", "1");
    exe.root_module.addCMacro("HAVE___ISNANF", "1");

    if (target.result.cpu.arch.isX86()) {
        exe.root_module.addCMacro("PENTIUM", "1");
        exe.root_module.addCMacro("X86_64_SYSTEM", "1");
    }

    if (target.result.os.tag == .windows) {
        exe.root_module.addCMacro("ODE_PLATFORM_WINDOWS", "1");
        exe.root_module.addCMacro("WIN32", "1");
        exe.root_module.addCMacro("_OU_TARGET_OS", "_OU_TARGET_OS_WINDOWS");
        // There are macro definitions for cygwin in ODE, but Zig's supreme leader said
        // that Zig will not support cygwin:
        // https://github.com/ziglang/zig/issues/751#issuecomment-2163680840
    } else if (target.result.os.tag == .macos) {
        exe.root_module.addCMacro("HAVE_APPLE_OPENGL_FRAMEWORK", "1");
        exe.root_module.addCMacro("ODE_PLATFORM_OSX", "1");
        exe.root_module.addCMacro("macintosh", "1");
        exe.root_module.addCMacro("_OU_TARGET_OS", "_OU_TARGET_OS_MAC");
    } else if (target.result.os.tag == .linux) {
        exe.root_module.addCMacro("ODE_PLATFORM_LINUX", "1");
        exe.root_module.addCMacro("_OU_TARGET_OS", "_OU_TARGET_OS_GENUNIX");
    } else if (target.result.os.tag == .freebsd) {
        exe.root_module.addCMacro("ODE_PLATFORM_FREEBSD", "1");
        exe.root_module.addCMacro("_OU_TARGET_OS", "_OU_TARGET_OS_GENUNIX");
    }
}

fn defineOptimizationMacros(exe: *std.Build.Step.Compile, optimize: std.builtin.OptimizeMode) void {
    if (optimize != .Debug) {
        exe.root_module.addCMacro("dNODEBUG", "1");
    }
}
