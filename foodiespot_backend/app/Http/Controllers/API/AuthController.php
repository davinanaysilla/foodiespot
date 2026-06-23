<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{
    // --- REGISTER ---
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role'     => 'user', // Semua pendaftar baru otomatis jadi 'user'
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'message' => 'Registrasi berhasil',
            'data'    => $user,
            'token'   => $token
        ], 201);
    }

    // --- LOGIN ---
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $user = User::where('email', $request->email)->first();

        // Validasi Login
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kredensial tidak valid. Email atau password salah.'
            ], 401);
        }

        // Validasi Suspend
        if ($user->is_suspended) {
            return response()->json([
                'status' => 'error',
                'message' => 'Akun Anda telah ditangguhkan.'
            ], 403);
        }

        // Create Token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'message' => 'Login berhasil',
            'data'    => $user,
            'token'   => $token
        ], 200);
    }

    // Logout
    public function logout(Request $request)
    {
        // Pastikan user benar-benar terdeteksi oleh Sanctum sebelum menghapus token
        if ($request->user()) {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'status'  => 'success',
                'message' => 'Berhasil logout'
            ], 200);
        }

        return response()->json([
            'status'  => 'error',
            'message' => 'Sesi tidak valid'
        ], 401);
    }

    // --- LIHAT PROFIL ---
    public function profile(Request $request)
    {
        $user = $request->user()->loadCount(['reviews', 'photos', 'favorites']);
        return response()->json([
            'status' => 'success',
            'data'   => $user
        ], 200);
    }

    // --- EDIT PROFIL (termasuk upload foto profil) ---
    public function updateProfile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'         => 'sometimes|required|string|max:255',
            'phone'        => 'sometimes|nullable|string|max:20',
            'password'     => 'sometimes|nullable|string|min:6|confirmed',
            'photo'        => 'sometimes|nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 400);
        }

        $user = $request->user();
        $dataUpdate = [];

        if ($request->has('name')) {
            $dataUpdate['name'] = $request->name;
        }

        if ($request->has('phone')) {
            $dataUpdate['phone'] = $request->phone;
        }

        if ($request->filled('password')) {
            $dataUpdate['password'] = Hash::make($request->password);
        }

        // Jika ada upload foto profil baru
        if ($request->hasFile('photo')) {
            // Hapus foto lama jika ada
            if ($user->photo_url && Storage::disk('public')->exists($user->photo_url)) {
                Storage::disk('public')->delete($user->photo_url);
            }
            $dataUpdate['photo_url'] = $request->file('photo')->store('profile_photos', 'public');
        }

        $user->update($dataUpdate);

        return response()->json([
            'status'  => 'success',
            'message' => 'Profil berhasil diperbarui',
            'data'    => $user->fresh()
        ], 200);
    }

    // --- HAPUS AKUN ---
    public function deleteAccount(Request $request)
    {
        $user = $request->user();

        // Hapus foto profil jika ada
        if ($user->photo_url && Storage::disk('public')->exists($user->photo_url)) {
            Storage::disk('public')->delete($user->photo_url);
        }

        // Hapus semua token lalu hapus akun
        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Akun berhasil dihapus'
        ], 200);
    }
}