<?php

namespace Database\Seeders;

use App\Models\City;
use App\Models\Faq;
use App\Models\Page;
use Illuminate\Database\Seeder;

class GeneralDataSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Cities
        City::create([
            'name' => ['en' => 'Damascus', 'ar' => 'دمشق'],
            'is_active' => true,
        ]);
        
        City::create([
            'name' => ['en' => 'Dubai', 'ar' => 'دبي'],
            'is_active' => true,
        ]);

        // 2. Pages
        Page::create([
            'slug' => 'privacy-policy',
            'title' => ['en' => 'Privacy Policy', 'ar' => 'سياسة الخصوصية'],
            'content' => [
                'en' => '<p>This is the English privacy policy...</p>',
                'ar' => '<p>هذه هي سياسة الخصوصية باللغة العربية...</p>',
            ],
        ]);

        Page::create([
            'slug' => 'terms-and-conditions',
            'title' => ['en' => 'Terms and Conditions', 'ar' => 'الشروط والأحكام'],
            'content' => [
                'en' => '<p>These are the terms and conditions...</p>',
                'ar' => '<p>هذه هي الشروط والأحكام...</p>',
            ],
        ]);

        Page::create([
            'slug' => 'about-us',
            'title' => ['en' => 'About Us', 'ar' => 'معلومات عنا'],
            'content' => [
                'en' => '<p>About iFix-Pro services...</p>',
                'ar' => '<p>حول خدمات iFix-Pro...</p>',
            ],
        ]);

        // 3. FAQs
        Faq::create([
            'question' => ['en' => 'How can I book a service?', 'ar' => 'كيف يمكنني حجز خدمة؟'],
            'answer' => ['en' => '<p>You can book through our mobile app.</p>', 'ar' => '<p>يمكنك الحجز من خلال تطبيق الهاتف المحمول الخاص بنا.</p>'],
            'sort_order' => 1,
        ]);

        Faq::create([
            'question' => ['en' => 'What payment methods are accepted?', 'ar' => 'ما هي طرق الدفع المقبولة؟'],
            'answer' => ['en' => '<p>We accept Wallet and Cash on Delivery.</p>', 'ar' => '<p>نحن نقبل الدفع عبر المحفظة والدفع عند الاستلام.</p>'],
            'sort_order' => 2,
        ]);

        Faq::create([
            'question' => ['en' => 'How do I contact support?', 'ar' => 'كيف يمكنني التواصل مع الدعم؟'],
            'answer' => ['en' => '<p>Use the Contact Us form in the app.</p>', 'ar' => '<p>استخدم نموذج اتصل بنا في التطبيق.</p>'],
            'sort_order' => 3,
        ]);
    }
}
