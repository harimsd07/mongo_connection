<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Support\Facades\Request;
use Illuminate\Support\Facades\Response; // ✅ Add this

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::all();
        return Response::json($products); // ✅ No warning
    }

    public function store(Request $request)
    {
        $product = Product::create($request->all());
        return Response::json($product, 201);
    }

    public function show(string $id)
    {
        $product = Product::findOrFail($id);
        return Response::json($product);
    }

    public function update(Request $request, string $id)
    {
        $product = Product::findOrFail($id);
        $product->update($request->all());
        return Response::json($product);
    }

    public function destroy(string $id)
    {
        Product::findOrFail($id)->delete();
        return Response::json(['message' => 'Product deleted successfully']);
    }
}
