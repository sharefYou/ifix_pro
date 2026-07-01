<?php

namespace Database\Seeders;

use App\Models\Service;
use App\Models\ServiceCategory;
use Illuminate\Database\Seeder;

class ServiceSeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name' => ['en' => 'Smartphone & Tablet Repair', 'ar' => 'صيانة الهواتف والأجهزة الذكية'],
                'description' => ['en' => 'Professional repair for iPhones, iPads, Android smartphones, screen & battery replacements.', 'ar' => 'صيانة احترافية لهواتف آيفون، آيباد، وأجهزة أندرويد، استبدال الشاشات والبطاريات بضمان.'],
                'icon' => 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?auto=format&fit=crop&w=500&q=80',
                'services' => [
                    [
                        'name' => ['en' => 'Original Screen Replacement', 'ar' => 'استبدال الشاشة المكسورة بأخرى أصلية'],
                        'description' => ['en' => 'Full OLED/LCD screen replacement with touch sensor calibration and 30-day warranty.', 'ar' => 'استبدال كامل للشاشة (OLED/LCD) مع معايرة اللمس وضمان كامل لمدة 30 يوماً.'],
                        'price' => 150.00,
                        'image' => 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Battery Replacement & Health Check', 'ar' => 'تغيير البطارية وفحص كفاءة الشحن'],
                        'description' => ['en' => 'Replace degraded battery with a high-capacity original battery unit.', 'ar' => 'استبدال البطارية الضعيفة ببطارية أصلية عالية السعة لإعادة أداء هاتفك كالجديد.'],
                        'price' => 75.00,
                        'image' => 'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Charging Port & Speaker Repair', 'ar' => 'إصلاح منفذ الشحن ومكبر الصوت'],
                        'description' => ['en' => 'Fix loose charging connections, microphone glitches, or muffled speakers.', 'ar' => 'إصلاح مشاكل منفذ الشحن، ضعف الصوت، أو أعطال الميكروفون أثناء المكالمات.'],
                        'price' => 60.00,
                        'image' => 'https://images.unsplash.com/photo-1563770660941-20978e870e26?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Water Damage Diagnostic & Cleanup', 'ar' => 'معالجة التلف الناتج عن السوائل والمياه'],
                        'description' => ['en' => 'Ultrasonic chemical cleaning and corrosion removal for water-damaged devices.', 'ar' => 'تنظيف كيميائي بالموجات فوق الصوتية وإزالة الصدأ للأجهزة المتعرضة للسوائل.'],
                        'price' => 95.00,
                        'image' => 'https://images.unsplash.com/photo-1512054502232-10a0a035d672?auto=format&fit=crop&w=800&q=80',
                    ],
                ]
            ],
            [
                'name' => ['en' => 'Computer & Laptop Maintenance', 'ar' => 'صيانة الحواسيب واللابتوب'],
                'description' => ['en' => 'Hardware upgrades, motherboard diagnostics, OS installation, and overheating solutions.', 'ar' => 'ترقية الأجهزة، فحص اللوحة الأم، تنصيب البرامج وأنظمة التشغيل، وحل مشاكل الحرارة.'],
                'icon' => 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?auto=format&fit=crop&w=500&q=80',
                'services' => [
                    [
                        'name' => ['en' => 'Deep Cleaning & Thermal Paste Application', 'ar' => 'تنظيف داخلي وتغيير المعجون الحراري'],
                        'description' => ['en' => 'Complete internal dust cleanup and premium thermal paste application to stop thermal throttling.', 'ar' => 'تنظيف شامل للأتربة الداخلية ووضع معجون حراري فائق الجودة لحل مشاكل السخونة والبطء.'],
                        'price' => 85.00,
                        'image' => 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'SSD Upgrade & RAM Expansion', 'ar' => 'ترقية القرص الصلب SSD وزيادة الرام'],
                        'description' => ['en' => 'Boost your computer speed up to 10x with high-speed NVMe SSD and additional RAM.', 'ar' => 'تسريع أداء حاسوبك حتى 10 أضعاف مع تركيب قرص NVMe SSD سريع وذاكرة عشوائية إضافية.'],
                        'price' => 140.00,
                        'image' => 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Windows / macOS Fresh Installation', 'ar' => 'تنصيب نظام التشغيل والتعاريف الشاملة'],
                        'description' => ['en' => 'Clean operating system install with genuine drivers, office suite, and antivirus setup.', 'ar' => 'تثبيت نظيف لنظام التشغيل مع جميع التعريفات الرسمية وحزمة الأوفيس ومكافح الفيروسات.'],
                        'price' => 50.00,
                        'image' => 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Laptop Hinges & Housing Repair', 'ar' => 'إصلاح مفصلات وهويكل اللابتوب المكسورة'],
                        'description' => ['en' => 'Precision fabrication and repair for broken laptop screen hinges and cracked covers.', 'ar' => 'إصلاح وتدعيم المفصلات المكسورة وتعديل هيكل الشاشة الخارجي بدقة متناهية.'],
                        'price' => 110.00,
                        'image' => 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?auto=format&fit=crop&w=800&q=80',
                    ],
                ]
            ],
            [
                'name' => ['en' => 'Air Conditioning & Refrigeration', 'ar' => 'صيانة التكييف والتبريد'],
                'description' => ['en' => 'AC cleaning, gas refill, leak diagnostics, and refrigerator compressor repairs.', 'ar' => 'غسيل المكيفات، تعبئة غاز الفريون، كشف التسريب، وتصليح ضواغط الثلاجات.'],
                'icon' => 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=500&q=80',
                'services' => [
                    [
                        'name' => ['en' => 'Split AC Deep Pressure Wash', 'ar' => 'غسيل وصيانة المكيف السبلت بضغط الماء'],
                        'description' => ['en' => 'Thorough pressure cleaning of indoor and outdoor AC units with anti-bacterial treatment.', 'ar' => 'غسيل شامل بالضغط للوحدات الداخلية والخارجية مع تعقيم مضاد للبكتيريا والروائح.'],
                        'price' => 100.00,
                        'image' => 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Freon Gas Refill & Leak Repair', 'ar' => 'تعبئة غاز الفريون ولحام أنابيب التسريب'],
                        'description' => ['en' => 'Check line pressure, repair copper tube leakage, and refill original Freon R410A/R22.', 'ar' => 'فحص ضغط الغاز، معالجة التسريب في الأنابيب النحاسية، وتعبئة فريون أصلي عالي التبريد.'],
                        'price' => 135.00,
                        'image' => 'https://images.unsplash.com/photo-1581094288338-2314dddb7ece?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Refrigerator & Freezer Repair', 'ar' => 'صيانة وتصليح الثلاجات والمجمدات المنزلية'],
                        'description' => ['en' => 'Fix cooling failure, compressor replacement, defrost timers, and door seal replacement.', 'ar' => 'إصلاح توقف التبريد، تغيير الضاغط (الكمبروسر)، حساسات الذوبان، وجلد الأبواب.'],
                        'price' => 160.00,
                        'image' => 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80',
                    ],
                ]
            ],
            [
                'name' => ['en' => 'Electrical Services', 'ar' => 'الأعمال الكهربائية المنزلية'],
                'description' => ['en' => 'Short circuit repair, lighting & chandeliers installation, switchboards troubleshooting.', 'ar' => 'إصلاح الالتماس الكهربائي، تركيب الثريات والإنارة، وصيانة لوحات التوزيع والقواطع.'],
                'icon' => 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=500&q=80',
                'services' => [
                    [
                        'name' => ['en' => 'Short Circuit & Fault Diagnostics', 'ar' => 'كشف وإصلاح الالتماس والأعطال الكهربائية'],
                        'description' => ['en' => 'Rapid detection of power outages, tripping breakers, and damaged wiring inspection.', 'ar' => 'تحديد سريع لأسباب انقطاع التيار الكهربائي أو هبوط القواطع وإصلاح الأسلاك التالفة.'],
                        'price' => 90.00,
                        'image' => 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Chandelier & LED Lighting Setup', 'ar' => 'تركيب الثريات ووحدات الإضاءة الحديثة'],
                        'description' => ['en' => 'Professional safe mounting of heavy chandeliers, LED strips, and smart dimmers.', 'ar' => 'تركيب آمن للثريات الثقيلة، إضاءة مخفية LED، والمفاتيح الذكية باحترافية عالية.'],
                        'price' => 70.00,
                        'image' => 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?auto=format&fit=crop&w=800&q=80',
                    ],
                ]
            ],
            [
                'name' => ['en' => 'Plumbing & Water Systems', 'ar' => 'أعمال السباكة والتمديدات الصحية'],
                'description' => ['en' => 'Leak repairs, drain unclogging, water heater maintenance, and mixer faucets replacement.', 'ar' => 'إصلاح التسربات، تسليك المجاري والأنابيب، صيانة السخانات، وتغيير خلاطات المياه.'],
                'icon' => 'https://images.unsplash.com/photo-1581094288338-2314dddb7ece?auto=format&fit=crop&w=500&q=80',
                'services' => [
                    [
                        'name' => ['en' => 'Electronic Water Leak Detection', 'ar' => 'كشف تسربات المياه بأحدث الأجهزة الإلكترونية'],
                        'description' => ['en' => 'Non-destructive acoustic and acoustic leak detection behind walls and under floor tiles.', 'ar' => 'كشف دقيق لمواقع التسرب خلف الجدران وتحت البلاط دون الحاجة للتكسير العشوائي.'],
                        'price' => 120.00,
                        'image' => 'https://images.unsplash.com/photo-1581094288338-2314dddb7ece?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Water Heater Installation & Repair', 'ar' => 'تركيب وصيانة سخانات المياه الكهربائية'],
                        'description' => ['en' => 'Replace heating elements, safety valves, thermostat adjustment, or new boiler installation.', 'ar' => 'تغيير قلب السخان، صمام الأمان، ضبط الثرموستات، أو تركيب سخان جديد بالكامل.'],
                        'price' => 85.00,
                        'image' => 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Faucet & Sanitary Ware Installation', 'ar' => 'تغيير خلاطات المياه والأدوات الصحية'],
                        'description' => ['en' => 'Install or replace washbasin faucets, shower mixers, bidet sprays, and sink valves.', 'ar' => 'تركيب واستبدال خلاطات المغاسل، دش الاستحمام، المحابس الأساسية، وأحواض المطبخ.'],
                        'price' => 65.00,
                        'image' => 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80',
                    ],
                ]
            ],
            [
                'name' => ['en' => 'Home Appliances Repair', 'ar' => 'صيانة الأجهزة المنزلية الكبيرة'],
                'description' => ['en' => 'Washing machines, dishwashers, electric/gas ovens, and microwave repair specialists.', 'ar' => 'خبراء صيانة الغسالات، جلايات الأطباق، الأفران الغازية والكهربائية، وأجهزة الميكروويف.'],
                'icon' => 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=500&q=80',
                'services' => [
                    [
                        'name' => ['en' => 'Automatic Washing Machine Repair', 'ar' => 'تصليح غسالات الملابس الأوتوماتيك'],
                        'description' => ['en' => 'Fix drainage errors, spin motor failure, drum bearing replacement, and electronic board repair.', 'ar' => 'إصلاح أعطال التصريف، دوران الحوض، تغيير الرمان بلي، وصيانة اللوحة الإلكترونية.'],
                        'price' => 145.00,
                        'image' => 'https://images.unsplash.com/photo-1626808642875-0aa545482dfb?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Gas & Electric Oven Servicing', 'ar' => 'صيانة الأفران وأجهزة الطهي الغازية والكهربائية'],
                        'description' => ['en' => 'Unclog burner jets, replace heating coils, thermocouple sensors, and oven door hinges.', 'ar' => 'تنظيف وتسليك عيون الغاز، تغيير شمعات التسخين، حساسات الأمان، ومفصلات الأبواب.'],
                        'price' => 115.00,
                        'image' => 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80',
                    ],
                ]
            ],
            [
                'name' => ['en' => 'Smart Home & CCTV Security', 'ar' => 'أنظمة المراقبة والشبكات والمنازل الذكية'],
                'description' => ['en' => 'Security cameras installation, Wi-Fi mesh networks, intercoms, and smart door locks.', 'ar' => 'تركيب كاميرات المراقبة، تقوية شبكات الواي فاي، الإنتركم، والأقفال الذكية.'],
                'icon' => 'https://images.unsplash.com/photo-1558002038-1055907df827?auto=format&fit=crop&w=500&q=80',
                'services' => [
                    [
                        'name' => ['en' => '4K CCTV Security Cameras Setup', 'ar' => 'تأسيس وتركيب كاميرات المراقبة بدقة 4K'],
                        'description' => ['en' => 'Full installation of IP/AHD cameras with DVR/NVR configuration and mobile remote view.', 'ar' => 'تركيب متكامل لكاميرات المراقبة مع ضبط جهاز التسجيل وربط البث المباشر بهاتفك المحمول.'],
                        'price' => 210.00,
                        'image' => 'https://images.unsplash.com/photo-1558002038-1055907df827?auto=format&fit=crop&w=800&q=80',
                    ],
                    [
                        'name' => ['en' => 'Home Mesh Wi-Fi & Network Cabling', 'ar' => 'تمديد شبكات الإنترنت وأجهزة Mesh Wi-Fi'],
                        'description' => ['en' => 'Eliminate Wi-Fi dead zones in large apartments and villas with high-speed Cat6 cabling.', 'ar' => 'التخلص من نقاط ضعف الإنترنت في المنازل والفلل عبر تمديد شبكي وتركيب مقويات إشارة فائقة.'],
                        'price' => 150.00,
                        'image' => 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=800&q=80',
                    ],
                ]
            ],
        ];

        foreach ($categories as $catData) {
            $category = ServiceCategory::updateOrCreate([
                'name' => $catData['name'],
            ], [
                'description' => $catData['description'],
                'icon' => $catData['icon'],
            ]);

            foreach ($catData['services'] as $srvData) {
                Service::updateOrCreate([
                    'category_id' => $category->id,
                    'name' => $srvData['name'],
                ], [
                    'description' => $srvData['description'],
                    'price' => $srvData['price'],
                    'image' => $srvData['image'],
                ]);
            }
        }
    }
}
