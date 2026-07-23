import '../models.dart';

// Science subjects for Telangana Intermediate (MPC, BiPC)
const scienceSubjectsYear1 = [
  Subject(
    id: 'physics1',
    name: 'Physics I',
    emoji: '⚛️',
    year: 1,
    chapters: [
      Chapter(id: 'phy1_ch1', title: 'Physical World', points: ['Scope and excitement of physics', 'Nature of physical laws']),
      Chapter(id: 'phy1_ch2', title: 'Units and Measurements', points: ['Units, dimensions, errors']),
      Chapter(id: 'phy1_ch3', title: 'Motion in Straight Line', points: ['Position, velocity, acceleration']),
    ],
    shortAnswers: [
      QA(q: 'What is physics?', a: 'Physics is study of matter, energy and their interactions.'),
    ],
    essays: [
      QA(q: 'Explain scope and excitement of physics (10 marks)', a: 'Physics scope: macroscopic and microscopic, excitement: explains natural phenomena...'),
    ],
    pdfUrl: 'https://tgbie.cgg.gov.in/scannedPhotos/Circulars/Physics_I_EM_MQP.pdf',
    pdfLabel: 'Physics I Model Paper - TSBIE Official',
  ),
  Subject(
    id: 'chemistry1',
    name: 'Chemistry I',
    emoji: '🧪',
    year: 1,
    chapters: [
      Chapter(id: 'chem1_ch1', title: 'Atomic Structure', points: ['Atoms, orbitals, quantum numbers']),
    ],
    shortAnswers: [QA(q: 'What is atom?', a: 'Smallest particle of element.')],
    essays: [QA(q: 'Explain atomic structure', a: 'Atom has nucleus with protons, neutrons, electrons in orbitals...')],
    pdfUrl: 'https://tgbie.cgg.gov.in/scannedPhotos/Circulars/Chemistry_I_EM_MQP.pdf',
    pdfLabel: 'Chemistry I Model Paper',
  ),
  Subject(
    id: 'botany1',
    name: 'Botany I',
    emoji: '🌱',
    year: 1,
    chapters: [Chapter(id: 'bot1_ch1', title: 'Cell', points: ['Cell structure, organelles'])],
    shortAnswers: [QA(q: 'What is cell?', a: 'Basic unit of life.')],
    essays: [QA(q: 'Explain cell structure', a: 'Cell has cell wall, membrane, cytoplasm, nucleus...')],
    pdfUrl: 'https://tgbie.cgg.gov.in/modelQuestionPapers.do',
    pdfLabel: 'Botany I - TSBIE Official',
  ),
  Subject(
    id: 'zoology1',
    name: 'Zoology I',
    emoji: '🦁',
    year: 1,
    chapters: [Chapter(id: 'zoo1_ch1', title: 'Animal Diversity', points: ['Classification, levels'])],
    shortAnswers: [QA(q: 'What is zoology?', a: 'Study of animals.')],
    essays: [QA(q: 'Explain animal diversity', a: 'Animals classified based on...')],
    pdfUrl: 'https://tgbie.cgg.gov.in/modelQuestionPapers.do',
    pdfLabel: 'Zoology I - TSBIE Official',
  ),
];

const scienceSubjectsYear2 = [
  Subject(
    id: 'physics2',
    name: 'Physics II',
    emoji: '⚛️',
    year: 2,
    chapters: [Chapter(id: 'phy2_ch1', title: 'Waves', points: ['Wave motion, superposition'])],
    shortAnswers: [QA(q: 'What is wave?', a: 'Disturbance carrying energy.')],
    essays: [QA(q: 'Explain waves', a: 'Wave is disturbance...')],
    pdfUrl: 'https://tgbie.cgg.gov.in/scannedPhotos/Circulars/Physics_II_EM_MQP.pdf',
    pdfLabel: 'Physics II Model Paper',
  ),
  Subject(
    id: 'chemistry2',
    name: 'Chemistry II',
    emoji: '🧪',
    year: 2,
    chapters: [Chapter(id: 'chem2_ch1', title: 'Solid State', points: ['Crystal systems'])],
    shortAnswers: [QA(q: 'What is solid state?', a: 'State with fixed shape and volume.')],
    essays: [QA(q: 'Explain solid state', a: 'Solids have...')],
    pdfUrl: 'https://tgbie.cgg.gov.in/scannedPhotos/Circulars/Chemistry_II_EM_MQP.pdf',
    pdfLabel: 'Chemistry II Model Paper',
  ),
];
