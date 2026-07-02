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
        $cities = [
            ['en' => 'Damascus', 'ar' => 'دمشق'],
            ['en' => 'Rif Dimashq', 'ar' => 'ريف دمشق'],
            ['en' => 'Aleppo', 'ar' => 'حلب'],
            ['en' => 'Homs', 'ar' => 'حمص'],
            ['en' => 'Hama', 'ar' => 'حماة'],
            ['en' => 'Latakia', 'ar' => 'اللاذقية'],
            ['en' => 'Tartus', 'ar' => 'طرطوس'],
            ['en' => 'Idlib', 'ar' => 'إدلب'],
            ['en' => 'Daraa', 'ar' => 'درعا'],
            ['en' => 'As-Suwayda', 'ar' => 'السويداء'],
            ['en' => 'Quneitra', 'ar' => 'القنيطرة'],
            ['en' => 'Deir ez-Zor', 'ar' => 'دير الزور'],
            ['en' => 'Raqqa', 'ar' => 'الرقة'],
            ['en' => 'Al-Hasakah', 'ar' => 'الحسكة'],
        ];

        foreach ($cities as $city) {
            City::updateOrCreate(
                ['name' => $city],
                ['is_active' => true]
            );
        }

        // 2. Pages
        Page::updateOrCreate([
            'slug' => 'privacy-policy',
        ], [
            'title' => ['en' => 'Privacy Policy', 'ar' => 'سياسة الخصوصية'],
            'content' => [
                'en' => '<h3>1. Information Collection</h3><p>At iFix-Pro, we take your privacy seriously. We collect essential information such as name, contact number, and location coordinates solely to connect customers with verified technicians and ensure service delivery.</p><h3>2. Data Protection</h3><p>All transactions and personal data are securely encrypted. We do not sell or share your personal details with third-party marketing companies.</p><h3>3. Location Services</h3><p>Our app uses accurate geolocation to send the nearest available expert directly to your doorstep in real-time.</p>',
                'ar' => '<h3>1. جمع المعلومات</h3><p>في iFix-Pro، نحن نولي اهتماماً بالغاً بخصوصيتك. نقوم بجمع المعلومات الأساسية مثل الاسم ورقم الهاتف والموقع الجغرافي فقط لتوصيل العملاء بالفنيين المعتمدين وضمان جودة الخدمة.</p><h3>2. حماية البيانات</h3><p>جميع المعاملات والبيانات الشخصية مشفرة بالكامل. نحن لا نبيع أو نشارك بياناتك الشخصية مع شركات التسويق التابعة لجهات خارجية.</p><h3>3. خدمات الموقع</h3><p>يستخدم تطبيقنا التحديد الدقيق للموقع لإرسال أقرب خبير متاح مباشرة إلى باب منزلك في أسرع وقت.</p>',
            ],
        ]);

        Page::updateOrCreate([
            'slug' => 'terms-and-conditions',
        ], [
            'title' => ['en' => 'Terms and Conditions', 'ar' => 'الشروط والأحكام'],
            'content' => [
                'en' => '<h3>1. Service Agreement</h3><p>By using iFix-Pro, you agree to abide by our service protocols. All technicians are independent professionals verified by our quality assurance team.</p><h3>2. Pricing & Payments</h3><p>Service fees listed in the app are transparent. Payment can be made via secured digital wallet balance or cash upon completion of the service visit.</p><h3>3. Warranty Policy</h3><p>We offer a 30-day workmanship guarantee on all completed repair jobs booked through the platform.</p>',
                'ar' => '<h3>1. اتفاقية الخدمة</h3><p>باستخدامك لتطبيق iFix-Pro، فإنك توافق على الالتزام ببروتوكولات الخدمة الخاصة بنا. جميع الفنيين هم محترفون مستقلون تم التحقق من كفاءتهم وهوياتهم من قبل فريق ضمان الجودة لدينا.</p><h3>2. الأسعار والدفع</h3><p>رسوم الخدمات المدرجة في التطبيق تتسم بالشفافية الوضوح. يمكن الدفع عبر رصيد المحفظة الرقمية الآمنة أو نقداً عند الانتهاء من زيارة الصيانة.</p><h3>3. سياسة الضمان</h3><p>نحن نقدم ضماناً لمدة 30 يوماً على جودة التنفيذ لجميع أعمال الصيانة المنجزة التي يتم حجزها عبر المنصة.</p>',
            ],
        ]);

        Page::updateOrCreate([
            'slug' => 'about-us',
        ], [
            'title' => ['en' => 'About Us', 'ar' => 'معلومات عنا'],
            'content' => [
                'en' => '<h3>Welcome to iFix-Pro</h3><p>iFix-Pro is your premier smart platform for professional home maintenance and electronic repairs. Whether you need urgent air conditioning servicing, smartphone screen replacement, or expert plumbing, we bridge the gap between skilled craftsmen and homeowners.</p><p>Our mission is to deliver fast, reliable, and standardized technical services with transparent pricing and guaranteed customer satisfaction.</p>',
                'ar' => '<h3>مرحباً بكم في iFix-Pro</h3><p>تطبيق iFix-Pro هو المنصة الذكية الرائدة لخدمات الصيانة المنزلية والإلكترونية الاحترافية. سواء كنت بحاجة إلى صيانة عاجلة لأجهزة التكييف، أو استبدال شاشة الهاتف الذكي، أو أعمال السباكة والكهرباء المتخصصة، فإننا نسد الفجوة بين الفنيين المهرة وأصحاب المنازل.</p><p>مهمتنا هي تقديم خدمات فنية سريعة وموثوقة ومعتمدة بأسعار شفافة وضمان رضا العملاء بنسبة 100%.</p>',
            ],
        ]);

        // 3. FAQs
        $faqs = [
            [
                'q' => ['en' => 'How can I book a maintenance service?', 'ar' => 'كيف يمكنني حجز خدمة صيانة؟'],
                'a' => ['en' => '<p>Simply browse our service categories, choose the specific repair you need, select a preferred date and time, and confirm your booking. Our system will immediately assign a verified technician nearby.</p>', 'ar' => '<p>ببساطة تصفح أقسام الخدمات، اختر الخدمة المطلوبة، حدد التاريخ والوقت المناسبين لك، ثم قم بتأكيد الحجز. سيقوم نظامنا فوراً بتعيين فني معتمد بالقرب منك.</p>'],
                'order' => 1,
            ],
            [
                'q' => ['en' => 'Are all technicians verified and qualified?', 'ar' => 'هل جميع الفنيين معتمدون ومؤهلون؟'],
                'a' => ['en' => '<p>Yes! Every technician on iFix-Pro undergoes strict identity verification, background checks, and professional technical testing before being approved on the platform.</p>', 'ar' => '<p>نعم! يخضع كل فني في iFix-Pro للتحقق الدقيق من الهوية والفحص الأمني والاختبار الفني المهني قبل اعتماده في المنصة.</p>'],
                'order' => 2,
            ],
            [
                'q' => ['en' => 'What payment methods are supported?', 'ar' => 'ما هي طرق الدفع المتاحة؟'],
                'a' => ['en' => '<p>You can pay conveniently using your digital Wallet inside the app (recharged via cards or online transfers) or pay Cash on Delivery directly to the technician after job completion.</p>', 'ar' => '<p>يمكنك الدفع بسهولة باستخدام محفظتك الرقمية داخل التطبيق (والتي يمكن شحنها ببطاقات الشحن أو التحويلات) أو الدفع نقداً عند الاستلام مباشرة للفني بعد إتمام العمل.</p>'],
                'order' => 3,
            ],
            [
                'q' => ['en' => 'Is there a warranty on the repairs?', 'ar' => 'هل يوجد ضمان على أعمال الصيانة؟'],
                'a' => ['en' => '<p>Absolutely. We provide a 30-day service warranty on all completed repairs. If the same issue reoccurs within 30 days, we will inspect and fix it at no extra cost.</p>', 'ar' => '<p>بكل تأكيد. نحن نقدم ضمان صيانة لمدة 30 يوماً على جميع الأعمال المنجزة. في حال تكرر نفس العطل خلال 30 يوماً، سنقوم بالفحص والإصلاح دون أي تكلفة إضافية.</p>'],
                'order' => 4,
            ],
            [
                'q' => ['en' => 'Can I request a custom repair not listed in categories?', 'ar' => 'هل يمكنني طلب صيانة خاصة غير مدرجة في الأقسام؟'],
                'a' => ['en' => '<p>Yes! You can use the "Custom Request" section in the app to describe your specific problem, attach photos, and receive competitive price bids from qualified professionals.</p>', 'ar' => '<p>نعم! يمكنك استخدام قسم "طلب خاص" في التطبيق لوصف مشكلتك المحددة وإرفاق الصور، لتتلقى عروض أسعار تنافسية مباشرة من الفنيين المتخصصين.</p>'],
                'order' => 5,
            ],
            [
                'q' => ['en' => 'How do I contact customer support?', 'ar' => 'كيف يمكنني التواصل مع خدمة العملاء؟'],
                'a' => ['en' => '<p>You can reach out via the in-app Contact Us form or directly through our automated support center available 24/7 to resolve any inquiries.</p>', 'ar' => '<p>يمكنك التواصل معنا عبر نموذج "اتصل بنا" داخل التطبيق أو مباشرة عبر مركز الدعم الفني المتاح على مدار الساعة طوال أيام الأسبوع لحل أي استفسارات.</p>'],
                'order' => 6,
            ],
        ];

        foreach ($faqs as $faq) {
            Faq::updateOrCreate([
                'question' => $faq['q'],
            ], [
                'answer' => $faq['a'],
                'is_active' => true,
                'sort_order' => $faq['order'],
            ]);
        }
    }
}
