import Image from 'next/image';
import Footer from "@/components/Footer";

export default function About() {
    // Array com os caminhos das imagens
    const imagePaths = [
        '/image/1.png',
        '/image/2.png',
        '/image/3.png',
        '/image/4.png',
        '/image/5.png',
    ];

    return (
        <div className="container px-4 py-5">
            <div className="row">
                {imagePaths.map((src, index) => (
                    <div key={index} className="col-12">
                        <Image 
                            src={src} 
                            alt={`Imagem ${index + 1}`} 
                            width={700} 
                            height={500} 
                            layout="responsive"
                        />
                    </div>
                ))}
            </div>
            <Footer />
        </div>
    );
}
